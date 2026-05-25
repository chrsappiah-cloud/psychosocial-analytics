# App Store submission checklist — v1.0.0

Complete every item before uploading build `1.0.0 (1)` to App Store Connect.

## 1. Apple Developer account

- [ ] Active Apple Developer Program membership
- [ ] App ID created: `com.wcs.psychosocial.app`
- [ ] Capabilities enabled: **In-App Purchase**, **iCloud** (CloudKit + Documents), **Apple Pay** (Merchant ID: `merchant.com.wcs.psychosocialanalytics`)
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

Consumables for Apple Pay:

- `com.wcs.psychosocial.report`
- `com.wcs.psychosocial.consultation`

Attach to the app version before submission.

## 5. Apple Pay (PassKit)

- [ ] Merchant ID `merchant.com.wcs.psychosocialanalytics` created in Apple Developer portal
- [ ] Merchant ID enabled in App ID `com.wcs.psychosocial.app`
- [ ] Payment processing certificate configured

## 6. Screenshots & preview

- [ ] 6.7" iPhone screenshots (required) — see `screenshot-spec.md`
- [ ] 6.5" or 5.5" screenshots (if supporting older sizes)
- [ ] iPad screenshots (app supports iPad)
- [ ] Optional App Preview video

Recommended screens: Login, Home dashboard, Upload hub, New Client, Assessment detail, Settings, Admin panel.

## 7. Build & upload

```bash
# Regenerate project
xcodegen generate

# Run CI-equivalent tests locally
xcodebuild test -scheme PsychosocialAnalytics \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PsychosocialAnalyticsTests \
  CODE_SIGNING_ALLOWED=NO

# Archive in Xcode: Product -> Archive -> Distribute -> App Store Connect
```

## 8. App Review information

- [ ] Sign-in required: **Yes** — Public (any email) or Administrator (admin@psychosocialanalytics.com / admin123)
- [ ] Notes: Login screen appears on launch; admin panel visible after admin sign-in; Apple Pay uses PassKit
- [ ] Contact info for App Review team

## 9. Post-submission

- [ ] Enable TestFlight internal testing
- [ ] Monitor App Review status
- [ ] Plan production release after approval

## CI/CD

GitHub Actions runs on every push/PR to `main` and `develop`:

- Build Debug for iOS Simulator
- Run all `PsychosocialAnalyticsTests` (45+ tests)
- Run all `PsychosocialAnalyticsUITests` (UI tests)
- Verify distribution files exist

Release tags `v*.*.*` trigger additional Release validation workflow.
