import XCTest
@testable import PsychosocialAnalytics

/// Middleware + backend + database working together (no UI).
final class IntegrationTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testRepositoryLoadsFromDatabaseAfterSync() async throws {
        let dir = try TestFixtures.tempDirectory()
        let database = try LocalDatabase(directory: dir)
        let assessment = TestFixtures.makeAssessment()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            if request.httpMethod == "POST" {
                return (response, MockBackendResponses.syncAssessments(count: 1))
            }
            return (response, MockBackendResponses.fetchAssessments([assessment]))
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let client = APIClient(
            baseURL: URL(string: "https://api.test.local")!,
            session: URLSession(configuration: config)
        )
        let backend = PsychosocialBackendService(client: client)
        let repository = AssessmentRepository(database: database, backend: backend)

        try await repository.saveAssessments([assessment])
        let sync = try await repository.syncWithBackend()
        XCTAssertEqual(sync.syncedCount, 1)

        let loaded = try await repository.loadAssessments()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.status, .draft)
    }

    func testRepositoryFallsBackToBackendWhenDatabaseEmpty() async throws {
        let dir = try TestFixtures.tempDirectory()
        let database = try LocalDatabase(directory: dir)
        let remote = [TestFixtures.makeAssessment(status: .inReview)]

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockBackendResponses.fetchAssessments(remote))
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let backend = PsychosocialBackendService(
            client: APIClient(
                baseURL: URL(string: "https://api.test.local")!,
                session: URLSession(configuration: config)
            )
        )
        let repository = AssessmentRepository(database: database, backend: backend)

        let loaded = try await repository.loadAssessments()
        XCTAssertEqual(loaded.first?.status, .inReview)
        XCTAssertTrue(database.exists(collection: AssessmentRepository.assessmentsCollection))
    }

    @MainActor
    func testViewModelPersistsSectionEditsToDatabase() async throws {
        let repository = try TestFixtures.makeRepository()
        let vm = AssessmentViewModel(
            repository: repository,
            aiService: MockGenAIService()
        )
        try await Task.sleep(nanoseconds: 100_000_000)
        guard let id = vm.assessments.first?.id else {
            XCTFail("Missing assessment")
            return
        }
        let section = AssessmentSection.presentingProblem
        let fields = AssessmentSectionSchema.fields(for: section)
        vm.resetSection(assessmentID: id, section: section)
        vm.setValue("Integrated note", assessmentID: id, section: section, field: fields[0])
        await vm.persistNow()

        let reloaded = AssessmentViewModel(repository: repository, aiService: MockGenAIService())
        await reloaded.reload()
        XCTAssertEqual(
            reloaded.value(assessmentID: id, section: section, fieldKey: fields[0].id),
            "Integrated note"
        )
    }
}
