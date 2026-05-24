import Foundation
import UniformTypeIdentifiers

public enum UploadServiceError: Error, LocalizedError, Sendable {
    case accessDenied(String)
    case invalidURL
    case downloadFailed(String)
    case unsupportedType
    case emptyPayload

    public var errorDescription: String? {
        switch self {
        case .accessDenied(let m): return m
        case .invalidURL: return "The URL is not valid."
        case .downloadFailed(let m): return m
        case .unsupportedType: return "This file type is not supported."
        case .emptyPayload: return "No data to upload."
        }
    }
}

@MainActor
public final class UploadService: ObservableObject {
    @Published public private(set) var uploads: [MediaUpload] = []
    @Published public private(set) var isUploading = false

    private let storage: StorageCoordinator
    private let database: LocalDatabaseProtocol
    private let access: AccessControlService
    private let uploadsCollection = "media_uploads"

    public init(
        storage: StorageCoordinator = .makeDefault(),
        database: LocalDatabaseProtocol? = nil,
        access: AccessControlService = .shared
    ) {
        self.storage = storage
        if let database {
            self.database = database
        } else {
            let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("PsychosocialAnalytics/Uploads", isDirectory: true)
            self.database = (try? LocalDatabase(directory: dir)) ?? LocalDatabase(
                persistence: PersistenceService(baseURL: dir)
            )
        }
        self.access = access
        loadUploads()
    }

    public func loadUploads() {
        if let saved: [MediaUpload] = try? database.load([MediaUpload].self, collection: uploadsCollection) {
            uploads = saved
        }
    }

    private func persist() {
        try? database.save(uploads, collection: uploadsCollection)
    }

    public static func mediaKind(for url: URL, mimeType: String) -> MediaKind {
        let ext = url.pathExtension.lowercased()
        if mimeType.hasPrefix("video/") || ["mov", "mp4", "m4v", "avi"].contains(ext) { return .video }
        if mimeType.hasPrefix("audio/") || ["m4a", "mp3", "wav", "aac", "caf"].contains(ext) { return .audio }
        if mimeType.hasPrefix("image/") || ["jpg", "jpeg", "png", "heic", "gif", "webp"].contains(ext) { return .image }
        if mimeType.hasPrefix("text/") || ["txt", "md", "json", "csv", "rtf"].contains(ext) { return .text }
        if ext == "pdf" { return .pdf }
        if ["zip", "gz", "tar"].contains(ext) { return .archive }
        if ["doc", "docx", "pages", "xls", "xlsx", "ppt", "pptx"].contains(ext) { return .document }
        return .other
    }

    public func uploadFile(
        data: Data,
        fileName: String,
        mimeType: String,
        source: UploadSource,
        clientID: UUID? = nil
    ) async throws -> MediaUpload {
        do { try access.require(.uploadMedia) } catch {
            throw UploadServiceError.accessDenied((error as? AccessDeniedReason)?.rawValue ?? "Access denied")
        }
        guard !data.isEmpty else { throw UploadServiceError.emptyPayload }

        isUploading = true
        defer { isUploading = false }

        var item = MediaUpload(
            clientID: clientID,
            fileName: fileName,
            mimeType: mimeType,
            kind: Self.mediaKind(for: URL(fileURLWithPath: fileName), mimeType: mimeType),
            source: source,
            byteSize: Int64(data.count),
            status: .uploading
        )

        uploads.insert(item, at: 0)
        persist()

        do {
            item = try await storage.uploadMedia(item, data: data)
            if let idx = uploads.firstIndex(where: { $0.id == item.id }) {
                uploads[idx] = item
            }
            persist()
            AppCoordinator.shared.showNotification("Uploaded \(fileName)", type: .success)
            return item
        } catch {
            item.status = UploadStatus.failed
            item.errorMessage = error.localizedDescription
            if let idx = uploads.firstIndex(where: { $0.id == item.id }) {
                uploads[idx] = item
            }
            persist()
            AppCoordinator.shared.showNotification("Upload failed", type: .error)
            throw error
        }
    }

    public func uploadText(_ text: String, title: String, clientID: UUID? = nil) async throws -> MediaUpload {
        let data = Data(text.utf8)
        return try await uploadFile(
            data: data,
            fileName: "\(title).txt",
            mimeType: "text/plain",
            source: .pasteboard,
            clientID: clientID
        )
    }

    public func importFromExternalURL(_ urlString: String, clientID: UUID? = nil) async throws -> MediaUpload {
        do { try access.require(.importFromURL) } catch {
            throw UploadServiceError.accessDenied((error as? AccessDeniedReason)?.rawValue ?? "Access denied")
        }
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme?.lowercased(),
              ["https", "http"].contains(scheme) else {
            throw UploadServiceError.invalidURL
        }

        isUploading = true
        defer { isUploading = false }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw UploadServiceError.downloadFailed("Could not download from URL.")
        }

        let fileName = url.lastPathComponent.isEmpty ? "import-\(UUID().uuidString)" : url.lastPathComponent
        let mime = (response as? HTTPURLResponse)?
            .value(forHTTPHeaderField: "Content-Type") ?? "application/octet-stream"

        var item = try await uploadFile(
            data: data,
            fileName: fileName,
            mimeType: mime,
            source: .externalURL,
            clientID: clientID
        )
        if let idx = uploads.firstIndex(where: { $0.id == item.id }) {
            uploads[idx].externalSourceURL = url.absoluteString
            persist()
        }
        return uploads.first(where: { $0.id == item.id }) ?? item
    }

    public func saveNewClient(_ draft: NewClientDraft) async throws -> Client {
        do { try access.require(.manageClients) } catch {
            throw UploadServiceError.accessDenied((error as? AccessDeniedReason)?.rawValue ?? "Access denied")
        }
        let client = Client(
            id: draft.id,
            fullName: draft.fullName,
            dateOfBirth: draft.dateOfBirth,
            riskLevel: draft.riskLevel
        )
        var clients: [Client] = (try? database.load([Client].self, collection: "clients")) ?? []
        clients.insert(client, at: 0)
        try database.save(clients, collection: "clients")
        if !draft.notes.isEmpty {
            _ = try? await uploadText(draft.notes, title: "\(draft.fullName)-intake-notes", clientID: client.id)
        }
        AppCoordinator.shared.showNotification("Client \(draft.fullName) added", type: .success)
        return client
    }

    public func loadClients() throws -> [Client] {
        if database.exists(collection: "clients") {
            return try database.load([Client].self, collection: "clients")
        }
        return []
    }
}

#if canImport(UniformTypeIdentifiers)
public extension UploadService {
    static var supportedDocumentTypes: [UTType] {
        [
            .plainText, .utf8PlainText, .json, .pdf, .image, .audio, .video, .movie,
            .mpeg4Movie, .quickTimeMovie, .mp3, .wav, .aiff, .data, .archive, .zip
        ]
    }
}
#endif
