import XCTest
@testable import PsychosocialAnalytics

@MainActor
final class AccessControlServiceTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: AccessControlService.savedProfileKey)
        super.tearDown()
    }

    func testStandardUserHasExpectedPermissions() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "User", role: .user)
        )

        XCTAssertTrue(access.can(.viewDashboard))
        XCTAssertTrue(access.can(.uploadMedia))
        XCTAssertTrue(access.can(.manageAssessments))
        XCTAssertFalse(access.can(.manageAccess))
        XCTAssertFalse(access.can(.configureStorage))
        XCTAssertFalse(access.isAdministrator)
    }

    func testAdministratorHasManageAccessAndStorage() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "admin@test.com", displayName: "Admin", role: .administrator)
        )

        XCTAssertTrue(access.isAdministrator)
        XCTAssertTrue(access.can(.manageAccess))
        XCTAssertTrue(access.can(.configureStorage))
    }

    func testInactiveAccountDeniesAllPermissions() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(
                email: "inactive@test.com",
                displayName: "Inactive",
                role: .administrator,
                isActive: false
            )
        )

        XCTAssertFalse(access.can(.viewDashboard))
        XCTAssertFalse(access.can(.manageAccess))
    }

    func testRequireThrowsInactiveAccount() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "U", role: .user, isActive: false)
        )

        XCTAssertThrowsError(try access.require(.uploadMedia)) { error in
            XCTAssertEqual(error as? AccessDeniedReason, .inactiveAccount)
        }
    }

    func testRequireThrowsAdministratorOnlyForManageAccess() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "U", role: .user)
        )

        XCTAssertThrowsError(try access.require(.manageAccess)) { error in
            XCTAssertEqual(error as? AccessDeniedReason, .administratorOnly)
        }
    }

    func testNonAdminCannotUpdateUser() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "User", role: .user)
        )

        access.updateUser(role: .administrator, isActive: false)

        XCTAssertEqual(access.currentUser.role, .user)
        XCTAssertTrue(access.currentUser.isActive)
    }

    func testAdminCanUpdateUserRoleAndActiveState() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "admin@test.com", displayName: "Admin", role: .administrator)
        )

        access.updateUser(role: .user, isActive: false)

        XCTAssertEqual(access.currentUser.role, .user)
        XCTAssertFalse(access.currentUser.isActive)
        XCTAssertFalse(access.can(.uploadMedia))
    }

    func testPromoteToAdministratorGrantsAdminPermissions() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "User", role: .user)
        )

        access.promoteToAdministrator()

        XCTAssertTrue(access.isAdministrator)
        XCTAssertTrue(access.can(.manageAccess))
    }

    func testPersistAndLoadSavedProfile() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "saved@test.com", displayName: "Saved", role: .user)
        )
        access.persistCurrentUser()

        let reloaded = AccessControlService()
        XCTAssertEqual(reloaded.currentUser.email, "saved@test.com")
        XCTAssertEqual(reloaded.currentUser.displayName, "Saved")
    }

    func testProfileFixtureLoadsFromJSON() throws {
        let profile = try FixtureLoader.decode(AppUserProfile.self, named: "clinician-active", subdirectory: "Profiles")
        XCTAssertEqual(profile.email, "clinician@example.com")
        XCTAssertEqual(profile.role, .user)
        XCTAssertTrue(profile.isActive)
    }
}
