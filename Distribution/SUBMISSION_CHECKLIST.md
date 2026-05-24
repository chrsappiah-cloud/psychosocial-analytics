# App Store submission checklist — v1.0.0

Complete every item before uploading build `1.0.0 (1)` to App Store Connect.

## 1. Apple Developer account

- [ ] Active Apple Developer Program membership
- [ ] App ID created: `com.wcs.psychosocial.app`
- [ ] Capabilities enabled: **In-App Purchase**, **iCloud** (CloudKit + Documents) if using backups
- [ ] Provisioning profiles / automatic signing configured in Xcode

## 2. App Store Connect app record

- [ ] Create app with SKU `psychosocial-analytics-ios` (see `AppStoreConnect/metadata.json`)
- [ ] Primary language: English (U.S.)
- [ ] Category: Medical (secondary: Education)
- [ ] Age rating questionnaire completed (expected 4+)
- [ ] Privacy policy URL live: `https://www.psychosocialanalytics.com/privacy`
- [ ] Support URL live: `https://www.psychosocialanalytics.com/support`

## 3. Copy & metadata (paste from repo)

| Field | Source file |
|-------|-------------|
| Name, subtitle, description, keywords | `Distribution/AppStoreConnect/metadata.json` |
| Export compliance answers | `Distribution/AppStoreConnect/export-compliance-responses.md` |
| TestFlight notes | `Distribution/TestFlight/release-notes-1.0.0.md` |
| Review notes | `Distribution/AppStoreConnect/review-notes.txt` |
| Privacy nutrition labels | `Distribution/AppStoreConnect/privacy-nutrition-labels.json` |
| Screenshot capture guide | `Distribution/AppStoreConnect/screenshot-spec.md` |
| Upload steps | `Distribution/UPLOAD_TO_APP_STORE.md` |

## 4. In-App Purchases (StoreKit)

Create subscriptions in App Store Connect:

- `com.wcs.psychosocial.pro.monthly`
- `com.wcs.psychosocial.pro.yearly`
- `com.wcs.psychosocial.enterprise.monthly`

Attach to the app version before submission.

## 5. Screenshots & preview

- [ ] 6.7" iPhone screenshots (required)
- [ ] 6.5" or 5.5" screenshots (if supporting older sizes)
- [ ] iPad screenshots (app supports iPad)
- [ ] Optional App Preview video

Recommended screens: Home dashboard, Upload hub, New Client, Assessment detail, Settings/subscription.

## 6. Build & upload

```bash
# Regenerate project
xcodegen generate

# Run CI-equivalent tests locally
xcodebuild test -scheme PsychosocialAnalytics \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PsychosocialAnalyticsTests \
  CODE_SIGNING_ALLOWED=NO

# Archive in Xcode: Product → Archive → Distribute → App Store Connect
# Or CLI (with signing configured):
# xcodebuild -exportArchive -archivePath ... -exportOptionsPlist App/PsychosocialAnalyticsApp/ExportOptions.plist
```

## 7. App Review information

- [ ] Demo account: **Not required** (offline sample data)
- [ ] Notes: AI drafts are simulated; admin panel hidden in Release
- [ ] Contact info for App Review team

## 8. Post-submission

- [ ] Enable TestFlight internal testing
- [ ] Monitor App Review status
- [ ] Plan production release after approval

## CI/CD

GitHub Actions runs on every push/PR to `main` and `develop`:

- Build Debug for iOS Simulator
- Run all `PsychosocialAnalyticsTests` (45+ tests)
- Verify distribution files exist

Release tags `v*.*.*` trigger additional Release validation workflow.
