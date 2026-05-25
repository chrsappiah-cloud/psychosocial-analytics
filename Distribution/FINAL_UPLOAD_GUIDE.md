# Final Upload Guide — App Store Connect

## Prerequisites

Before uploading, ensure your local environment has:

1. **Apple Developer Program** — Active membership
2. **Code Signing** — Automatic signing configured in Xcode
3. **App Store Connect API Key** — Or Apple ID with app-specific password

## Step 1 — Screenshots (Upload to App Store Connect)

Upload the following to App Store Connect → Psychosocial Analytics → Distribution → iOS App → Version 1.0.0 → Screenshots:

### iPhone 6.7" Display
From `Distribution/screenshots/`:
| File | Caption |
|------|---------|
| `01-login.png` | Secure role-based sign-in |
| `02-home.png` | Caseload at a glance |
| `03-upload.png` | Upload text, audio, video, and documents |
| `04-assess.png` | Structured psychosocial assessments |
| `05-clients.png` | Client list with search |
| `06-insights.png` | Analytics and metrics |
| `07-reports.png` | Report list with badges |
| `08-settings.png` | Plans and administrator controls |
| `09-admin-overview.png` | Administrator dashboard |
| `10-admin-payments.png` | Subscription & payment management |
| `11-admin-apple-pay.png` | One-time purchases via Apple Pay |

### iPad 12.9" Display
From `Distribution/screenshots/ipad/`:
| File | Caption |
|------|---------|
| `01-home.png` | Caseload at a glance |
| `02-upload.png` | Upload hub |
| `03-clients.png` | Client list |
| `04-admin.png` | Admin panel |

## Step 2 — Create In-App Purchases

In App Store Connect → Features → In-App Purchases, create:

### Auto-Renewable Subscriptions
| Product ID | Type | Reference Name |
|------------|------|----------------|
| `com.wcs.psychosocial.pro.monthly` | Auto-Renewable Subscription | Professional Monthly |
| `com.wcs.psychosocial.pro.yearly` | Auto-Renewable Subscription | Professional Yearly |
| `com.wcs.psychosocial.enterprise.monthly` | Auto-Renewable Subscription | Enterprise Monthly |

### Consumables (Apple Pay)
| Product ID | Type | Reference Name |
|------------|------|----------------|
| `com.wcs.psychosocial.report` | Consumable | Single Report |
| `com.wcs.psychosocial.consultation` | Consumable | Consultation Fee |

## Step 3 — Apple Pay Merchant ID

In Apple Developer Portal:
1. Certificates, Identifiers & Profiles → Merchant IDs
2. Create with identifier: `merchant.com.wcs.psychosocialanalytics`
3. Enable for App ID `com.wcs.psychosocial.app`
4. Generate and download payment processing certificate

## Step 4 — Archive & Upload Build

### With Xcode (Recommended)
```bash
# Ensure code signing is configured
open PsychosocialAnalytics.xcodeproj
# Product → Archive → Distribute App → App Store Connect → Upload
```

### With Command Line (requires API key)
```bash
# Archive
xcodebuild archive \
  -scheme PsychosocialAnalytics \
  -destination 'generic/platform=iOS' \
  -archivePath build/PsychosocialAnalytics.xcarchive \
  -configuration Release

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/PsychosocialAnalytics.xcarchive \
  -exportOptionsPlist App/PsychosocialAnalyticsApp/ExportOptions.plist \
  -exportPath build/export

# Upload with altool
xcrun altool --upload-app \
  -f build/export/PsychosocialAnalyticsApp.ipa \
  --api-issuer <ISSUER_ID> \
  --api-key <KEY_ID>
```

## Step 5 — Attach Build & Configure Version

1. App Store Connect → Your App → Distribution → iOS App → Version 1.0.0
2. Select the uploaded build
3. Paste metadata from `Distribution/AppStoreConnect/inflight-1.0.0-paste.md`
4. Answer export compliance: **Yes, exempt** (standard HTTPS only)
5. Attach In-App Purchases to version
6. Complete App Privacy questionnaire (see `privacy-nutrition-labels.json`)

## Step 6 — Submit for Review

1. Verify all fields are complete
2. **Add for Review** → Submit
3. Monitor Resolution Center for questions

## Quick Reference — Key Files

| File | Purpose |
|------|---------|
| `Distribution/AppStoreConnect/submission-response.json` | Complete form response data |
| `Distribution/AppStoreConnect/inflight-1.0.0-paste.md` | Copy-paste template for version page |
| `Distribution/AppStoreConnect/metadata.json` | All textual metadata |
| `Distribution/AppStoreConnect/review-notes.txt` | App Review notes |
| `Distribution/AppStoreConnect/privacy-nutrition-labels.json` | Privacy questionnaire mapping |
| `Distribution/AppStoreConnect/export-compliance-responses.md` | Export compliance answers |
| `Distribution/SUBMISSION_CHECKLIST.md` | Pre-submission checklist |
| `Distribution/UPLOAD_TO_APP_STORE.md` | Detailed upload steps |
| `Distribution/screenshots/` | iPhone screenshots (11 files) |
| `Distribution/screenshots/ipad/` | iPad screenshots (4 files) |
