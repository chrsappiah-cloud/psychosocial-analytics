import Foundation

public class PersistenceService {
    public let baseURL: URL

    public init(baseURL: URL? = nil) {
        if let baseURL = baseURL {
            self.baseURL = baseURL
        } else {
            let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let supportDir = paths[0].appendingPathComponent("PsychosocialAnalytics", isDirectory: true)
            
            if !FileManager.default.fileExists(atPath: supportDir.path) {
                try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
            }
            self.baseURL = supportDir
        }
    }
    
    public func save<T: Encodable>(_ object: T, filename: String) throws {
        let url = baseURL.appendingPathComponent(filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url, options: .atomic)
    }
    
    public func load<T: Decodable>(filename: String) throws -> T {
        let url = baseURL.appendingPathComponent(filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
