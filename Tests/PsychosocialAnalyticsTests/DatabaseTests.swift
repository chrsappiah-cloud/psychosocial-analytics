import XCTest
@testable import PsychosocialAnalytics

final class DatabaseTests: XCTestCase {
    func testLocalDatabaseSaveLoadRoundTrip() throws {
        let dir = try TestFixtures.tempDirectory()
        let db = try LocalDatabase(directory: dir)
        let clients = [Client(fullName: "Ada Lovelace", dateOfBirth: Date(), riskLevel: 1)]
        try db.save(clients, collection: "clients")
        XCTAssertTrue(db.exists(collection: "clients"))
        let loaded: [Client] = try db.load([Client].self, collection: "clients")
        XCTAssertEqual(loaded.first?.fullName, "Ada Lovelace")
    }

    func testLocalDatabaseDeleteRemovesCollection() throws {
        let dir = try TestFixtures.tempDirectory()
        let db = try LocalDatabase(directory: dir)
        try db.save([TestFixtures.makeAssessment()], collection: "assessments")
        try db.delete(collection: "assessments")
        XCTAssertFalse(db.exists(collection: "assessments"))
    }

    func testPersistenceServiceAtomicWrite() throws {
        let dir = try TestFixtures.tempDirectory()
        let persistence = PersistenceService(baseURL: dir)
        try persistence.save(["alpha"], filename: "tags.json")
        let loaded: [String] = try persistence.load(filename: "tags.json")
        XCTAssertEqual(loaded, ["alpha"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: persistence.fileURL(for: "tags.json").path))
    }
}
