import XCTest
@testable import PsychosocialAnalytics

@MainActor
final class UploadAccessTests: XCTestCase {
    func testUserCanUploadWithProfessionalTier() async throws {
        let access = AccessControlService(
            currentUser: AppUserProfile(
                email: "user@test.com",
                displayName: "User",
                role: .user,
                tier: .professional
            )
        )
        XCTAssertTrue(access.can(.uploadMedia))
        XCTAssertTrue(access.can(.importFromURL))
        XCTAssertFalse(access.can(.manageAccess))
    }

    func testFreeTierCannotUpload() {
        let access = AccessControlService(
            currentUser: AppUserProfile(
                email: "free@test.com",
                displayName: "Free",
                role: .user,
                tier: .free
            )
        )
        XCTAssertFalse(access.can(.uploadMedia))
    }

    func testAdministratorHasFullPermissions() {
        let access = AccessControlService(
            currentUser: AppUserProfile(
                email: "admin@test.com",
                displayName: "Admin",
                role: .administrator,
                tier: .enterprise
            )
        )
        XCTAssertTrue(access.can(.manageAccess))
        XCTAssertTrue(access.can(.managePayments))
        XCTAssertTrue(access.can(.configureStorage))
    }

    func testUploadTextPersistsToStorage() async throws {
        let dir = try TestFixtures.tempDirectory()
        let database = try LocalDatabase(directory: dir)
        let storage = StorageCoordinator(primary: LocalSupabaseFallback(directory: dir), backups: [])
        let access = AccessControlService(
            currentUser: AppUserProfile(email: "u@t.com", displayName: "U", tier: .professional)
        )
        let service = UploadService(storage: storage, database: database, access: access)
        let item = try await service.uploadText("Clinical note body", title: "note")
        XCTAssertEqual(item.kind, .text)
        XCTAssertEqual(item.status, .synced)
        XCTAssertEqual(service.uploads.count, 1)
    }

    func testSaveNewClient() async throws {
        let dir = try TestFixtures.tempDirectory()
        let database = try LocalDatabase(directory: dir)
        let access = AccessControlService(
            currentUser: AppUserProfile(email: "u@t.com", displayName: "U", tier: .professional)
        )
        let service = UploadService(storage: StorageCoordinator(primary: LocalSupabaseFallback(directory: dir), backups: []), database: database, access: access)
        let client = try await service.saveNewClient(NewClientDraft(fullName: "Alex Rivera"))
        XCTAssertEqual(client.fullName, "Alex Rivera")
        let clients = try service.loadClients()
        XCTAssertTrue(clients.contains(where: { $0.id == client.id }))
    }

    func testStorageCoordinatorMirrorsToBackups() async throws {
        let dir = try TestFixtures.tempDirectory()
        let primary = LocalSupabaseFallback(directory: dir.appendingPathComponent("primary"))
        let backup = LocalSupabaseFallback(directory: dir.appendingPathComponent("backup"))
        let coordinator = StorageCoordinator(primary: primary, backups: [backup])
        var upload = MediaUpload(fileName: "test.txt", mimeType: "text/plain", kind: .text, source: .manualFile)
        let synced = try await coordinator.uploadMedia(upload, data: Data("hello".utf8))
        XCTAssertEqual(synced.status, .synced)
        XCTAssertNotNil(synced.remoteURL)
    }

    func testMediaKindDetection() {
        XCTAssertEqual(
            UploadService.mediaKind(for: URL(fileURLWithPath: "a.mp4"), mimeType: "video/mp4"),
            .video
        )
        XCTAssertEqual(
            UploadService.mediaKind(for: URL(fileURLWithPath: "a.m4a"), mimeType: "audio/mp4"),
            .audio
        )
    }
}
