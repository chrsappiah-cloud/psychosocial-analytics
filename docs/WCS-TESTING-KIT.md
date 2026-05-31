# WCS Testing Kit — Psychosocial Analytics

Concepts, tools, and workflows for product quality at World Class Services.

This kit adapts the WCS testing playbook to **Psychosocial Analytics**: a free iOS clinical documentation app with role-based access, uploads, assessments, and AI-assisted report drafts. There are **no in-app purchases, subscriptions, or payment flows**.

---

## What this kit covers

| Domain | Focus in this app |
|--------|-------------------|
| **Foundations** | Red-Green-Refactor, behavior-first tests, regression safety |
| **Test architecture** | XCTest structure, naming, assertions, `@testable import` |
| **Isolation** | Protocols, mocks, fakes, dependency injection |
| **Async & UI** | Expectations, main-thread UI updates, login and upload flows |
| **Networking & media** | API client slices, JSON fixtures, mock URL protocol |
| **Legacy refactoring** | Characterization tests before refactors, seam extraction |

---

## Core stack

- **XCTest** — unit and integration tests (`Tests/PsychosocialAnalyticsTests/`)
- **XCUITest** — critical user journeys (`UITests/PsychosocialAnalyticsUITests/`)
- **Xcode** — test navigator, coverage, breakpoints
- **Fixtures** — `Tests/Fixtures/` (JSON payloads and profile snapshots)
- **CI** — `.github/workflows/ci.yml` with unit tests, UI smoke tests, coverage gate

Run locally:

```bash
xcodegen generate
./scripts/run-all-tests.sh
```

---

## WCS service seams (this app)

Inject or mock these boundaries in tests:

| Service | Responsibility |
|---------|----------------|
| `AccessControlService` | Role checks, inactive account, admin permissions |
| `AuthSessionService` | Public/admin sign-in rules, display-name resolution |
| `AccountDeletionService` | On-device account wipe and sign-out |
| `UploadService` / `StorageCoordinator` | Uploads, sync, backup mirrors |
| `AssessmentRepository` | Assessment CRUD and section completion |
| `GenAIService` / `AIGenerationBackend` | AI draft generation |
| `PsychosocialBackendService` | Remote API fetch/sync |

---

## Test suites

| Suite | File(s) | Purpose |
|-------|---------|---------|
| Access control | `AccessControlServiceTests.swift` | Permissions, admin updates, persistence |
| Auth / login | `AuthSessionServiceTests.swift`, `LoginFlowUITests.swift` | Credential rules, sign-in flows |
| Account deletion | `AccountDeletionTests.swift` | Wipe, sign-out, defaults cleanup |
| Upload access | `UploadAccessTests.swift` | Active/inactive account upload gates |
| Assessments | `PsychosocialAnalyticsTests.swift`, `AssessmentViewModelAITests.swift` | Schema, bindings, AI integration |
| Backend | `BackendServiceTests.swift`, `MiddlewareTests.swift` | HTTP client, auth headers |
| Database | `DatabaseTests.swift` | Local persistence |
| E2E / integration | `EndToEndTests.swift`, `IntegrationTests.swift` | Cross-layer flows |
| UI smoke | `PsychosocialAnalyticsUITests.swift` | Tab navigation, settings, dashboard |

---

## Fixtures

Static assets live under `Tests/Fixtures/`:

```
Tests/Fixtures/
├── JSON/           # API response payloads
├── Profiles/       # Sample AppUserProfile JSON
└── README.md
```

Load via `FixtureLoader` in `Tests/PsychosocialAnalyticsTests/Support/TestSupport.swift`.

**Rule:** add or update a fixture when testing a new API contract or auth profile shape.

---

## Definition of done (per feature)

### Before coding
- Write at least one **failing test** for the new rule or seam.

### During coding
- Make the smallest change that turns red → green.

### After green
- Refactor naming, duplication, and seams without changing behavior.

### Before merge
- Verify **async**, **error**, **empty**, and **loading** states.
- Run unit + UI tests locally or rely on CI.
- Auth-sensitive changes must include tests in `AccessControlServiceTests` or `AuthSessionServiceTests`.

---

## CI gates

Every PR to `main` / `develop` must pass:

| Check | What it enforces |
|-------|------------------|
| **iOS Unit Tests** | All `PsychosocialAnalyticsTests` |
| **Coverage gate** | `PsychosocialAnalytics` line coverage ≥ 12% (`MIN_LINE_COVERAGE`; raise over time) |
| **iOS UI Tests** | Tab smoke + login flow UI tests |
| **Project integrity** | Required docs, fixtures, distribution files |

See `.github/BRANCH_PROTECTION.md` for required status check names.

---

## Patterns to follow

### Unit test naming

```swift
func testInactiveAccountCannotUpload() { ... }
func testSignInAdminFailsWithInvalidCredentials() { ... }
```

### Arrange-Act-Assert

```swift
let access = TestFixtures.isolatedAccessControl(currentUser: profile)
AuthSessionService.signInPublic(email: "u@example.com", displayName: "", role: .user, access: access)
XCTAssertTrue(access.can(.uploadMedia))
```

### Isolated access control in tests

Always clear saved profile when testing auth:

```swift
let access = TestFixtures.isolatedAccessControl(currentUser: profile)
// ...
UserDefaults.standard.removeObject(forKey: AccessControlService.savedProfileKey)
```

---

## What we intentionally do not test here

- StoreKit, Apple Pay, subscriptions, or paywall flows (removed from the app)
- Real network calls in unit tests (use `MockURLProtocol`)
- App Store Connect submission scripts (manual / release pipeline)

---

## Related docs

- [TESTING-AUDIT.md](TESTING-AUDIT.md) — coverage audit and prioritized backlog
- [README.md](../README.md) — quick start and test commands
- [CONFIGURATION.md](../CONFIGURATION.md) — backend setup

Built as an internal reference for WCS iOS product and engineering work.
