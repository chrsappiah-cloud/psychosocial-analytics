import XCTest
@testable import PsychosocialAnalytics

@MainActor
final class AccountDeletionTests: XCTestCase {
    private var appSupportURL: URL!

    override func setUp() {
        super.setUp()
        appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PsychosocialAnalytics", isDirectory: true)
        UserDefaults.standard.removeObject(forKey: AccessControlService.savedProfileKey)
        UserDefaults.standard.removeObject(forKey: "uitest_upload_segment")
        UserDefaults.standard.removeObject(forKey: "uitest_admin_section")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: appSupportURL)
        UserDefaults.standard.removeObject(forKey: AccessControlService.savedProfileKey)
        super.tearDown()
    }

    func testDeleteAccountResetsProfileAndSignsOut() throws {
        let access = AccessControlService(
            currentUser: AppUserProfile(
                email: "delete-me@test.com",
                displayName: "Delete Me",
                role: .user
            )
        )
        access.persistCurrentUser()
        XCTAssertNotNil(UserDefaults.standard.data(forKey: AccessControlService.savedProfileKey))

        let coordinator = AppCoordinator.shared
        coordinator.isAuthenticated = true

        try AccountDeletionService.shared.deleteAccount(access: access, coordinator: coordinator)

        XCTAssertFalse(coordinator.isAuthenticated)
        XCTAssertEqual(access.currentUser.email, "")
        XCTAssertNil(UserDefaults.standard.data(forKey: AccessControlService.savedProfileKey))
    }

    func testDeleteAccountShowsSuccessNotification() throws {
        let access = AccessControlService(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "U")
        )
        let coordinator = AppCoordinator.shared

        try AccountDeletionService.shared.deleteAccount(access: access, coordinator: coordinator)

        XCTAssertEqual(coordinator.notificationMessage, "Your account and local data have been deleted.")
        XCTAssertEqual(coordinator.notificationType, .success)
    }

    func testDeleteAccountRemovesLocalApplicationSupportData() throws {
        try FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        let marker = appSupportURL.appendingPathComponent("marker.txt")
        try Data("local-data".utf8).write(to: marker)

        let access = AccessControlService(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "U")
        )
        let coordinator = AppCoordinator.shared

        try AccountDeletionService.shared.deleteAccount(access: access, coordinator: coordinator)

        XCTAssertFalse(FileManager.default.fileExists(atPath: appSupportURL.path))
    }

    func testDeleteAccountClearsUITestDefaultsKeys() throws {
        UserDefaults.standard.set(1, forKey: "uitest_upload_segment")
        UserDefaults.standard.set(2, forKey: "uitest_admin_section")

        let access = AccessControlService(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "U")
        )

        try AccountDeletionService.shared.deleteAccount(
            access: access,
            coordinator: AppCoordinator.shared
        )

        XCTAssertNil(UserDefaults.standard.object(forKey: "uitest_upload_segment"))
        XCTAssertNil(UserDefaults.standard.object(forKey: "uitest_admin_section"))
    }

    func testResetAccountAfterDeletionClearsSavedProfile() {
        let access = AccessControlService(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "U")
        )
        access.persistCurrentUser()
        access.resetAccountAfterDeletion()
        XCTAssertNil(UserDefaults.standard.data(forKey: AccessControlService.savedProfileKey))
    }
}
