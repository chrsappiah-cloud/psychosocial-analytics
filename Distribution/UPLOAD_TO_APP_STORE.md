# Upload to App Store Connect

Step-by-step guide to upload **Psychosocial Analytics** build `1.0.0 (1)`.

## Prerequisites

- [ ] Apple Developer Program active
- [ ] App record created in [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Signing configured in Xcode (Team + Automatic signing)
- [ ] IAP products created (see `CONFIGURATION.md`)
- [ ] CI tests passed locally or on GitHub Actions

## Step 1 — Prepare metadata (copy from repo)

| App Store Connect field | File |
|-------------------------|------|
| Description, subtitle, keywords | `AppStoreConnect/metadata.json` |
| Review notes | `AppStoreConnect/review-notes.txt` |
| Export compliance | `AppStoreConnect/export-compliance-responses.md` |
| Privacy labels guide | `AppStoreConnect/privacy-nutrition-labels.json` |
| TestFlight “What to Test” | `TestFlight/release-notes-1.0.0.md` |

## Step 2 — Archive in Xcode

1. Open `PsychosocialAnalytics.xcodeproj`
2. Scheme: **PsychosocialAnalytics**
3. Destination: **Any iOS Device (arm64)**
4. **Product → Archive**
5. When Organizer opens: **Distribute App**
6. Choose **App Store Connect** → **Upload**
7. Options: include bitcode off (default), upload symbols **on**, manage version **off** (use Xcode project version)

Or export with CLI after archive:

```bash
xcodebuild -exportArchive \
  -archivePath ~/Library/Developer/Xcode/Archives/.../PsychosocialAnalytics.xcarchive \
  -exportOptionsPlist App/PsychosocialAnalyticsApp/ExportOptions.plist \
  -exportPath ./build/export
```

## Step 3 — Upload build

- In Organizer: **Distribute App → App Store Connect → Upload**
- Wait for processing (15–60 minutes)
- In App Store Connect → **TestFlight**: confirm build appears

## Step 4 — Attach build to version

1. App Store Connect → your app → **Distribution** → **iOS App**
2. Create version **1.0.0** if needed
3. Select the uploaded build
4. Paste metadata from `metadata.json`
5. Upload screenshots (see `screenshot-spec.md`)
6. Answer export compliance: **No** (standard encryption only)
7. Complete App Privacy questionnaire using `privacy-nutrition-labels.json`

## Step 5 — Submit for review

1. Add In-App Purchases to the version
2. Set pricing and availability
3. **Add for Review** → Submit

## Step 6 — TestFlight (optional first)

1. Internal testing group → add build
2. Share `release-notes-1.0.0.md` as testing instructions
3. After validation, promote same build to App Store review

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Missing compliance | Set `ITSAppUsesNonExemptEncryption` = false in Info.plist (already set) |
| Invalid binary | Bump `CURRENT_PROJECT_VERSION` in `project.yml`, run `xcodegen`, re-archive |
| IAP missing | Create product IDs in App Store Connect before submission |
| Processing stuck | Wait 2h; re-upload with incremented build number |
