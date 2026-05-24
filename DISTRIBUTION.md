# Distribution checklist — Psychosocial Analytics

## Before archiving

1. Open `PsychosocialAnalytics.xcodeproj` in Xcode.
2. Select the **PsychosocialAnalytics** target → **Signing & Capabilities**.
3. Set your **Team** and confirm **Automatically manage signing** is enabled.
4. Confirm **Bundle Identifier**: `com.wcs.psychosocial.app` (change if your org uses a different ID).
5. Update version numbers in the project (or `project.yml` then run `xcodegen`):
   - **Marketing Version** (`MARKETING_VERSION`) — user-facing, e.g. `1.0.0`
   - **Build** (`CURRENT_PROJECT_VERSION`) — increment for each upload

## Archive & upload

1. Scheme: **PsychosocialAnalytics** → destination **Any iOS Device**.
2. **Product → Archive**.
3. In the Organizer, **Distribute App** → App Store Connect (or Ad Hoc / TestFlight).

## Included for App Store compliance

- Dark UI enforced via `UIUserInterfaceStyle`
- `ITSAppUsesNonExemptEncryption` = false (standard HTTPS only)
- `PrivacyInfo.xcprivacy` for on-device file storage APIs
- App icon asset catalog (`AppIcon`)
- Medical/education category metadata

## Automated testing (before archive)

Run the full suite (SwiftPM + Xcode unit + UI):

```bash
chmod +x scripts/run-all-tests.sh
./scripts/run-all-tests.sh
```

Or individually:

```bash
swift test
xcodebuild test -scheme PsychosocialAnalytics -destination 'platform=iOS Simulator,name=iPhone 17'
```

Test layers covered:

| Layer | XCTest target | Examples |
|-------|---------------|----------|
| Database | `PsychosocialAnalyticsTests` | `LocalDatabase`, `PersistenceService` |
| Middleware | `PsychosocialAnalyticsTests` | `APIClient`, `RequestMiddleware` |
| Backend | `PsychosocialAnalyticsTests` | `PsychosocialBackendService`, mocks |
| Integration | `PsychosocialAnalyticsTests` | Repository + API + DB |
| End-to-end | `PsychosocialAnalyticsTests` | Full clinical workflow |
| UI | `PsychosocialAnalyticsUITests` | Tab bar, screens, controls |

Materials for App Store Connect live under `Distribution/AppStoreConnect/` and `Distribution/TestFlight/`.

**Submission pack** (zip for upload prep):

```bash
./scripts/prepare-submission-pack.sh 1.0.0
# → build/PsychosocialAnalytics-submission-1.0.0.zip
```

**App Store upload guide:** [Distribution/UPLOAD_TO_APP_STORE.md](Distribution/UPLOAD_TO_APP_STORE.md)

## CI/CD (GitHub Actions)

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `.github/workflows/ci.yml` | Push/PR to `main`, `develop` | Build + 45 unit tests (required to pass) |
| `.github/workflows/release.yml` | Tags `v*.*.*` | Release build validation + submission pack artifact |

Branch protection (recommended on GitHub):

- Require `CI / iOS Build & Test` before merge
- Require `CI / Project integrity` before merge

Full submission steps: [Distribution/SUBMISSION_CHECKLIST.md](Distribution/SUBMISSION_CHECKLIST.md)

## Regenerating the Xcode project

If you edit `project.yml`:

```bash
cd "/Applications/Psychosocial Analytics/Psychosocial Analytics"
xcodegen generate
```
