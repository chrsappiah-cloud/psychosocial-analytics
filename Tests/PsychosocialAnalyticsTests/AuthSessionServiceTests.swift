import XCTest
@testable import PsychosocialAnalytics

@MainActor
final class AuthSessionServiceTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: AccessControlService.savedProfileKey)
        super.tearDown()
    }

    func testResolvedDisplayNameUsesProvidedName() {
        XCTAssertEqual(
            AuthSessionService.resolvedDisplayName(email: "jane@example.com", displayName: "Dr. Jane Smith"),
            "Dr. Jane Smith"
        )
    }

    func testResolvedDisplayNameFallsBackToEmailLocalPart() {
        XCTAssertEqual(
            AuthSessionService.resolvedDisplayName(email: "alex.rivera@example.com", displayName: "   "),
            "alex.rivera"
        )
    }

    func testValidAdminCredentialsAcceptDefaultPair() {
        XCTAssertTrue(
            AuthSessionService.isValidAdminCredentials(
                email: " admin@psychosocialanalytics.com ",
                password: "admin123"
            )
        )
    }

    func testInvalidAdminCredentialsRejectWrongPassword() {
        XCTAssertFalse(
            AuthSessionService.isValidAdminCredentials(
                email: "admin@psychosocialanalytics.com",
                password: "wrong"
            )
        )
    }

    func testInvalidAdminCredentialsRejectWrongEmail() {
        XCTAssertFalse(
            AuthSessionService.isValidAdminCredentials(
                email: "not-admin@example.com",
                password: "admin123"
            )
        )
    }

    func testSignInPublicPersistsClinicianProfile() {
        let access = TestFixtures.isolatedAccessControl()

        AuthSessionService.signInPublic(
            email: "clinician@example.com",
            displayName: "",
            role: .user,
            access: access
        )

        XCTAssertEqual(access.currentUser.email, "clinician@example.com")
        XCTAssertEqual(access.currentUser.displayName, "clinician")
        XCTAssertEqual(access.currentUser.role, .user)
        XCTAssertTrue(access.can(.uploadMedia))
        XCTAssertNotNil(UserDefaults.standard.data(forKey: AccessControlService.savedProfileKey))
    }

    func testSignInPublicHonorsSelectedAdministratorRole() {
        let access = TestFixtures.isolatedAccessControl()

        AuthSessionService.signInPublic(
            email: "lead@example.com",
            displayName: "Lead Clinician",
            role: .administrator,
            access: access
        )

        XCTAssertEqual(access.currentUser.role, .administrator)
        XCTAssertTrue(access.can(.manageAccess))
    }

    func testSignInAdminSucceedsWithValidCredentials() {
        let access = TestFixtures.isolatedAccessControl()

        let signedIn = AuthSessionService.signInAdmin(
            email: "admin@psychosocialanalytics.com",
            password: "admin123",
            access: access
        )

        XCTAssertTrue(signedIn)
        XCTAssertTrue(access.isAdministrator)
        XCTAssertEqual(access.currentUser.email, "admin@psychosocialanalytics.com")
        XCTAssertEqual(access.currentUser.displayName, "Administrator")
    }

    func testSignInAdminFailsWithInvalidCredentials() {
        let access = TestFixtures.isolatedAccessControl(
            currentUser: AppUserProfile(email: "u@test.com", displayName: "User", role: .user)
        )

        let signedIn = AuthSessionService.signInAdmin(
            email: "admin@psychosocialanalytics.com",
            password: "bad-password",
            access: access
        )

        XCTAssertFalse(signedIn)
        XCTAssertFalse(access.isAdministrator)
        XCTAssertEqual(access.currentUser.email, "u@test.com")
    }
}
