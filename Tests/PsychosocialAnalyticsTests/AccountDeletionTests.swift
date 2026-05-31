import XCTest
@testable import PsychosocialAnalytics

@MainActor
final class AccountDeletionTests: XCTestCase {
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

    func testResetAccountAfterDeletionClearsSavedProfile() {
        let access = AccessControlService(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "U")
        )
        access.persistCurrentUser()
        access.resetAccountAfterDeletion()
        XCTAssertNil(UserDefaults.standard.data(forKey: AccessControlService.savedProfileKey))
    }
}
