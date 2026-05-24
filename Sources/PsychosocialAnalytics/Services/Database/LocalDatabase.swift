import Foundation

/// On-device JSON persistence (application support directory).
public protocol LocalDatabaseProtocol: Sendable {
    func save<T: Encodable>(_ value: T, collection: String) throws
    func load<T: Decodable>(_ type: T.Type, collection: String) throws -> T
    func exists(collection: String) -> Bool
    func delete(collection: String) throws
}

public final class LocalDatabase: LocalDatabaseProtocol, @unchecked Sendable {
    private let persistence: PersistenceService

    public init(persistence: PersistenceService) {
        self.persistence = persistence
    }

    public convenience init(directory: URL) throws {
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        self.init(persistence: PersistenceService(baseURL: directory))
    }

    public func save<T: Encodable>(_ value: T, collection: String) throws {
        try persistence.save(value, filename: fileName(for: collection))
    }

    public func load<T: Decodable>(_ type: T.Type, collection: String) throws -> T {
        try persistence.load(filename: fileName(for: collection))
    }

    public func exists(collection: String) -> Bool {
        let url = persistence.fileURL(for: fileName(for: collection))
        return FileManager.default.fileExists(atPath: url.path)
    }

    public func delete(collection: String) throws {
        let url = persistence.fileURL(for: fileName(for: collection))
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func fileName(for collection: String) -> String {
        "\(collection).json"
    }
}

extension PersistenceService {
    public func fileURL(for filename: String) -> URL {
        baseURL.appendingPathComponent(filename)
    }
}
