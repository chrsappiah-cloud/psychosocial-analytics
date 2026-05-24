import Foundation

public enum EnvironmentType: String {
    case development
    case staging
    case production
}

public class AppEnvironment: ObservableObject {
    public static let shared = AppEnvironment()
    
    @Published public var current: EnvironmentType = .development
    @Published public var apiBaseURL: URL = URL(string: "https://api.psychosocialanalytics.com")!
    
    public init() {}
    
    public func update(to environment: EnvironmentType) {
        self.current = environment
        switch environment {
        case .development:
            apiBaseURL = URL(string: "http://localhost:8000")!
        case .staging:
            apiBaseURL = URL(string: "https://staging.api.psychosocialanalytics.com")!
        case .production:
            apiBaseURL = URL(string: "https://api.psychosocialanalytics.com")!
        }
    }
}
