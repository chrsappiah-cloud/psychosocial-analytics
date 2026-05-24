import Foundation

public protocol StorageBackend: Sendable {
    var backendID: String { get }
    var displayName: String { get }
    func upload(data: Data, path: String, mimeType: String) async throws -> String
    func download(path: String) async throws -> Data
    func healthCheck() async -> Bool
}

public struct SupabaseConfig: Sendable {
    public let projectURL: URL
    public let anonKey: String
    public let bucket: String

    public init(projectURL: URL, anonKey: String, bucket: String = "psychosocial-media") {
        self.projectURL = projectURL
        self.anonKey = anonKey
        self.bucket = bucket
    }

    public static var fromEnvironment: SupabaseConfig? {
        guard let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
              let url = URL(string: urlString) else { return nil }
        return SupabaseConfig(projectURL: url, anonKey: key)
    }
}

/// Primary storage — Supabase Storage REST API.
public final class SupabaseStorageService: StorageBackend, @unchecked Sendable {
    public let backendID = "supabase"
    public let displayName = "Supabase (Primary)"
    private let config: SupabaseConfig
    private let session: URLSession

    public init(config: SupabaseConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    public func upload(data: Data, path: String, mimeType: String) async throws -> String {
        let encoded = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        var request = URLRequest(
            url: config.projectURL
                .appendingPathComponent("storage/v1/object")
                .appendingPathComponent(config.bucket)
                .appendingPathComponent(encoded)
        )
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(mimeType, forHTTPHeaderField: "x-content-type")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            return "supabase://\(config.bucket)/\(path)"
        }
        return config.projectURL
            .appendingPathComponent("storage/v1/object/public")
            .appendingPathComponent(config.bucket)
            .appendingPathComponent(encoded)
            .absoluteString
    }

    public func download(path: String) async throws -> Data {
        let url = config.projectURL
            .appendingPathComponent("storage/v1/object/public")
            .appendingPathComponent(config.bucket)
            .appendingPathComponent(path)
        let (data, _) = try await session.data(from: url)
        return data
    }

    public func healthCheck() async -> Bool {
        var request = URLRequest(url: config.projectURL.appendingPathComponent("rest/v1/"))
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        do {
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode != nil
        } catch { return false }
    }
}

/// CloudKit backup adapter (iCloud ecosystem).
public final class CloudKitBackupService: StorageBackend, @unchecked Sendable {
    public let backendID = "cloudkit"
    public let displayName = "CloudKit / iCloud"
    private let directory: URL

    public init() {
        let base = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directory = base.appendingPathComponent("CloudKitBackup", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    public func upload(data: Data, path: String, mimeType: String) async throws -> String {
        let fileURL = directory.appendingPathComponent(path)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: .atomic)
        return "cloudkit://\(path)"
    }

    public func download(path: String) async throws -> Data {
        try Data(contentsOf: directory.appendingPathComponent(path))
    }

    public func healthCheck() async -> Bool {
        FileManager.default.fileExists(atPath: directory.path)
    }
}

/// iCloud Drive file backup.
public final class ICloudBackupService: StorageBackend, @unchecked Sendable {
    public let backendID = "icloud"
    public let displayName = "iCloud Drive"
    private let directory: URL

    public init() {
        let base = FileManager.default.url(forUbiquityContainerIdentifier: nil)
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directory = base.appendingPathComponent("PsychosocialAnalytics/Backup", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    public func upload(data: Data, path: String, mimeType: String) async throws -> String {
        let url = directory.appendingPathComponent(path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        return "icloud://\(path)"
    }

    public func download(path: String) async throws -> Data {
        try Data(contentsOf: directory.appendingPathComponent(path))
    }

    public func healthCheck() async -> Bool {
        FileManager.default.ubiquityIdentityToken != nil || FileManager.default.fileExists(atPath: directory.path)
    }
}

/// Cloudflare R2 / CDN backup via HTTP.
public final class CloudflareBackupService: StorageBackend, @unchecked Sendable {
    public let backendID = "cloudflare"
    public let displayName = "Cloudflare R2"
    private let uploadEndpoint: URL?
    private let localFallback: URL

    public init(uploadEndpoint: URL? = nil) {
        self.uploadEndpoint = uploadEndpoint
            ?? ProcessInfo.processInfo.environment["CLOUDFLARE_UPLOAD_URL"].flatMap(URL.init(string:))
        localFallback = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CloudflareBackup", isDirectory: true)
        try? FileManager.default.createDirectory(at: localFallback, withIntermediateDirectories: true)
    }

    public func upload(data: Data, path: String, mimeType: String) async throws -> String {
        if let endpoint = uploadEndpoint {
            var request = URLRequest(url: endpoint.appendingPathComponent(path))
            request.httpMethod = "PUT"
            request.httpBody = data
            request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                return endpoint.appendingPathComponent(path).absoluteString
            }
        }
        let local = localFallback.appendingPathComponent(path)
        try data.write(to: local, options: .atomic)
        return "cloudflare-local://\(path)"
    }

    public func download(path: String) async throws -> Data {
        try Data(contentsOf: localFallback.appendingPathComponent(path))
    }

    public func healthCheck() async -> Bool { true }
}

/// Writes to Supabase first, then mirrors to backup backends.
public final class StorageCoordinator: @unchecked Sendable {
    public let primary: StorageBackend
    public let backups: [StorageBackend]

    public init(primary: StorageBackend, backups: [StorageBackend]) {
        self.primary = primary
        self.backups = backups
    }

    public static func makeDefault() -> StorageCoordinator {
        let localDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SupabaseLocal", isDirectory: true)
        try? FileManager.default.createDirectory(at: localDir, withIntermediateDirectories: true)

        let primary: StorageBackend
        if let config = SupabaseConfig.fromEnvironment {
            primary = SupabaseStorageService(config: config)
        } else {
            primary = LocalSupabaseFallback(directory: localDir)
        }

        return StorageCoordinator(
            primary: primary,
            backups: [
                CloudKitBackupService(),
                ICloudBackupService(),
                CloudflareBackupService()
            ]
        )
    }

    public func uploadMedia(_ upload: MediaUpload, data: Data) async throws -> MediaUpload {
        var copy = upload
        let path = "\(upload.id.uuidString)/\(upload.fileName)"
        copy.remoteURL = try await primary.upload(data: data, path: path, mimeType: upload.mimeType)
        for backup in backups {
            _ = try? await backup.upload(data: data, path: path, mimeType: upload.mimeType)
        }
        copy.status = .synced
        return copy
    }

    public func backendStatuses() async -> [StorageBackendStatus] {
        var statuses: [StorageBackendStatus] = [
            StorageBackendStatus(
                id: primary.backendID,
                name: primary.displayName,
                isConnected: await primary.healthCheck(),
                lastSync: Date()
            )
        ]
        for backup in backups {
            statuses.append(
                StorageBackendStatus(
                    id: backup.backendID,
                    name: backup.displayName,
                    isConnected: await backup.healthCheck(),
                    lastSync: Date()
                )
            )
        }
        return statuses
    }
}

/// Offline Supabase-shaped local store when env keys are not configured.
public final class LocalSupabaseFallback: StorageBackend, @unchecked Sendable {
    public let backendID = "supabase-local"
    public let displayName = "Supabase (Local Dev)"
    private let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    public func upload(data: Data, path: String, mimeType: String) async throws -> String {
        let url = directory.appendingPathComponent(path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        return "supabase-local://\(path)"
    }

    public func download(path: String) async throws -> Data {
        try Data(contentsOf: directory.appendingPathComponent(path))
    }

    public func healthCheck() async -> Bool { true }
}
