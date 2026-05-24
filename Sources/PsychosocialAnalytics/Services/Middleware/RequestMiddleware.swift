import Foundation

public struct APIRequest: Sendable {
    public let path: String
    public let method: String
    public let body: Data?
    public let headers: [String: String]

    public init(path: String,
                method: String = "GET",
                body: Data? = nil,
                headers: [String: String] = [:]) {
        self.path = path
        self.method = method
        self.body = body
        self.headers = headers
    }
}

public struct APIErrorResponse: Codable, Sendable {
    public let message: String
}

public enum APIClientError: Error, Equatable, Sendable {
    case invalidURL
    case httpStatus(Int, String?)
    case decodingFailed
    case transport(String)
}

/// Middleware hook applied before each HTTP request leaves the client.
public protocol RequestMiddleware: Sendable {
    func prepare(request: inout URLRequest, context: APIRequest) throws
}

/// Adds JSON content type and environment metadata.
public struct JSONContentTypeMiddleware: RequestMiddleware, Sendable {
    public init() {}

    public func prepare(request: inout URLRequest, context: APIRequest) throws {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("PsychosocialAnalytics/1.0", forHTTPHeaderField: "User-Agent")
    }
}

/// Injects bearer token when present.
public struct AuthorizationMiddleware: RequestMiddleware, Sendable {
    private let tokenProvider: @Sendable () -> String?

    public init(tokenProvider: @escaping @Sendable () -> String?) {
        self.tokenProvider = tokenProvider
    }

    public func prepare(request: inout URLRequest, context: APIRequest) throws {
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

public protocol APIClientProtocol: Sendable {
    func perform<T: Decodable & Sendable>(_ request: APIRequest, as type: T.Type) async throws -> T
}

public final class APIClient: APIClientProtocol, @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let middleware: [any RequestMiddleware]

    public init(baseURL: URL,
                session: URLSession = .shared,
                middleware: [any RequestMiddleware] = [JSONContentTypeMiddleware()]) {
        self.baseURL = baseURL
        self.session = session
        self.middleware = middleware
    }

    public func perform<T: Decodable & Sendable>(_ request: APIRequest,
                                                 as type: T.Type) async throws -> T {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        urlRequest.httpMethod = request.method
        urlRequest.httpBody = request.body
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        for mw in middleware {
            try mw.prepare(request: &urlRequest, context: request)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse else {
                throw APIClientError.transport("Non-HTTP response")
            }
            guard (200...299).contains(http.statusCode) else {
                let message = String(data: data, encoding: .utf8)
                throw APIClientError.httpStatus(http.statusCode, message)
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIClientError.decodingFailed
            }
        } catch let error as APIClientError {
            throw error
        } catch {
            throw APIClientError.transport(error.localizedDescription)
        }
    }
}
