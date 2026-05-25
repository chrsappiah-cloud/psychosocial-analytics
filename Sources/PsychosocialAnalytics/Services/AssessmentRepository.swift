import Foundation

public enum RepositoryError: Error, Equatable, Sendable {
    case databaseUnavailable
    case syncFailed(String)
}

/// Coordinates local database persistence with remote backend sync.
public protocol AssessmentRepositoryProtocol: Sendable {
    func loadAssessments() async throws -> [Assessment]
    func saveAssessments(_ assessments: [Assessment]) async throws
    func createAssessment() async throws -> Assessment
    func syncWithBackend() async throws -> SyncAssessmentsResponse
}

public final class AssessmentRepository: AssessmentRepositoryProtocol, @unchecked Sendable {
    public static let assessmentsCollection = "assessments"

    private let database: LocalDatabaseProtocol
    private let backend: PsychosocialBackendProtocol

    public init(database: LocalDatabaseProtocol, backend: PsychosocialBackendProtocol) {
        self.database = database
        self.backend = backend
    }

    public func loadAssessments() async throws -> [Assessment] {
        if database.exists(collection: Self.assessmentsCollection) {
            let local = try database.load([Assessment].self, collection: Self.assessmentsCollection)
            if !local.isEmpty { return local }
        }
        let remote = try await backend.fetchAssessments()
        if !remote.isEmpty {
            try database.save(remote, collection: Self.assessmentsCollection)
            return remote
        }
        return [defaultAssessment()]
    }

    public func saveAssessments(_ assessments: [Assessment]) async throws {
        try database.save(assessments, collection: Self.assessmentsCollection)
    }

    public func createAssessment() async throws -> Assessment {
        var list = try await loadAssessments()
        let created = Assessment(
            id: UUID(),
            organizationID: UUID(),
            createdByUserID: UUID(),
            clientID: UUID(),
            status: .draft,
            sections: [],
            riskFlags: [],
            aiDrafts: [],
            signatures: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        list.insert(created, at: 0)
        try await saveAssessments(list)
        return created
    }

    public func syncWithBackend() async throws -> SyncAssessmentsResponse {
        let local = try await loadAssessments()
        let response = try await backend.syncAssessments(local)
        try await saveAssessments(local)
        return response
    }

    private func defaultAssessment() -> Assessment {
        Assessment(
            id: UUID(),
            organizationID: UUID(),
            createdByUserID: UUID(),
            clientID: UUID(),
            status: .draft,
            sections: [],
            riskFlags: [],
            aiDrafts: [],
            signatures: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
