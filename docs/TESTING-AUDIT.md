# Testing audit — Psychosocial Analytics

**Audit date:** 2026-05-31  
**Kit reference:** [WCS-TESTING-KIT.md](WCS-TESTING-KIT.md)  
**Branch baseline:** post-IAP removal, role-only access control

---

## Executive summary

Psychosocial Analytics has a **solid unit-test foundation** (50+ tests) covering assessments, AI, backend, middleware, database, and uploads. This audit closed the largest gaps in **auth, access control, account deletion, and login flows**, added a **fixture structure**, and **hardened CI** with a coverage gate.

| Area | Status | Notes |
|------|--------|-------|
| Foundations (TDD, AAA) | ✅ Strong | Descriptive test names, isolated fixtures |
| Access control | ✅ Good | New `AccessControlServiceTests` |
| Auth / login | ✅ Good | `AuthSessionService` + unit + UI login tests |
| Account deletion | ✅ Good | Expanded wipe and notification tests |
| Assessments & AI | ✅ Strong | Existing VM, backend, E2E coverage |
| Networking | ✅ Good | Mock URL protocol, middleware tests |
| UI smoke | ⚠️ Partial | Tab navigation covered; upload/admin UI thin |
| Fixtures | ✅ Started | JSON + profile fixtures under `Tests/Fixtures/` |
| CI / coverage | ✅ Hardened | 12% line-coverage floor (`MIN_LINE_COVERAGE`; target 40%) |

---

## Current test inventory

### Unit tests (`PsychosocialAnalyticsTests`)

| File | Tests (approx.) | Coverage focus |
|------|-----------------|----------------|
| `AccessControlServiceTests.swift` | 10 | Permissions, admin updates, persistence, fixtures |
| `AuthSessionServiceTests.swift` | 9 | Credentials, public/admin sign-in |
| `AccountDeletionTests.swift` | 5 | Wipe, sign-out, defaults, notification |
| `UploadAccessTests.swift` | 7 | Upload permission gates |
| `PsychosocialAnalyticsTests.swift` | 4 | Tabs, env, schema, GenAI |
| `AssessmentViewModelAITests.swift` | — | AI draft integration |
| `AIGeneration*Tests.swift` | — | Backend, E2E, integration |
| `BackendServiceTests.swift` | — | API client |
| `MiddlewareTests.swift` | — | Auth / JSON middleware |
| `DatabaseTests.swift` | — | Local DB |
| `EndToEndTests.swift` / `IntegrationTests.swift` | — | Cross-layer |

### UI tests (`PsychosocialAnalyticsUITests`)

| File | Coverage focus |
|------|----------------|
| `LoginFlowUITests.swift` | Public login, admin login, invalid password |
| `PsychosocialAnalyticsUITests.swift` | Tab bar, dashboard, clients, settings |
| `AIGenerationUITests.swift` | AI draft UI |
| `AppStoreScreenshotUITests.swift` | Distribution screenshots |

---

## Gaps closed in this pass

1. **`AuthSessionService`** — extracted testable sign-in rules from `LoginView`
2. **`configureSession(role:)`** — fixed public login role assignment (was silently blocked by admin-only `updateUser`)
3. **`AccessControlServiceTests`** — permissions, `require`, admin updates, persistence
4. **`AuthSessionServiceTests`** — credential validation and session application
5. **`AccountDeletionTests`** — Application Support wipe, UI-test defaults, success notification
6. **`LoginFlowUITests`** — end-to-end login smoke without `--skip-login`
7. **`Tests/Fixtures/`** — JSON API payloads and profile snapshots
8. **CI coverage gate** — `scripts/check-coverage.sh`, minimum 30% line coverage

---

## Prioritized backlog

### P0 — Before next App Store submission

| # | Item | Rationale |
|---|------|-----------|
| 1 | Run full `./scripts/run-all-tests.sh` on release branch | Validates unit + UI + coverage locally |
| 2 | Confirm login UI tests pass on CI simulator | New `LoginFlowUITests` depend on accessibility IDs |

### P1 — High value, next sprint

| # | Item | Suggested test file |
|---|------|---------------------|
| 3 | Settings sign-out resets session | `AuthSessionServiceTests` or UI test |
| 4 | Admin tab hidden for non-admin users | `AccessControlServiceTests` + UI assertion |
| 5 | Upload hub permission denied for inactive users | UI test on upload tab |
| 6 | Use JSON fixtures in `BackendServiceTests` | Replace inline `MockBackendResponses` where duplicated |

### P2 — Medium term

| # | Item | Notes |
|---|------|-------|
| 7 | View-model tests for `ClientsView` / `DashboardView` | Extract logic if views are mostly declarative |
| 8 | Storage backend status tests | `StorageCoordinator` connected/offline states |
| 9 | Increase `MIN_LINE_COVERAGE` to 40% | After P1 tests land |
| 10 | PR coverage diff (changed files only) | Requires xcresult parsing or Danger/swiftlint plugin |

### P3 — Nice to have

| # | Item |
|---|------|
| 11 | Swift Testing migration for new suites only |
| 12 | Snapshot tests for branded components |
| 13 | Performance tests for large caseload lists |

---

## CI checklist

- [x] Unit tests on every PR (`PsychosocialAnalyticsTests`)
- [x] UI smoke + login tests on every PR
- [x] Coverage gate (30% minimum, configurable via `MIN_LINE_COVERAGE`)
- [x] Project integrity checks for kit + fixture docs
- [ ] Branch protection enabled in GitHub (see `.github/BRANCH_PROTECTION.md`)

---

## How to re-run this audit

1. Count tests: `xcodebuild test -only-testing:PsychosocialAnalyticsTests …`
2. Read coverage: `./scripts/check-coverage.sh build/TestResults.xcresult`
3. Map new features to kit seams in [WCS-TESTING-KIT.md](WCS-TESTING-KIT.md)
4. Update this backlog when gaps close or new domains appear

---

## Sign-off criteria (feature-ready)

A feature is **test-complete** per the WCS kit when:

- [ ] At least one unit test proves the core rule
- [ ] Error and empty states are covered if user-visible
- [ ] Auth or upload changes include access-control tests
- [ ] New API contracts have fixtures in `Tests/Fixtures/JSON/`
- [ ] CI is green on the PR branch
