# App Store submission checklist — v1.0.0 (build 4)

Complete every item before submitting build `1.0.0 (4)` to App Review.

## 1. Apple Developer account

- [ ] Active Apple Developer Program membership
- [ ] App ID: `wcs.Psychosocial--Analytics`
- [ ] Capabilities: **iCloud** (CloudKit + Documents) only — **do not** enable In-App Purchase or Apple Pay
- [ ] Provisioning profiles / automatic signing configured in Xcode

## 2. App Store Connect app record

- [ ] Primary language: English (U.S.)
- [ ] Category: Medical (secondary: Education)
- [ ] Age rating questionnaire completed (expected 4+)
- [ ] Privacy policy URL live: `https://www.psychosocialanalytics.com/privacy`
- [ ] Support URL live: `https://www.psychosocialanalytics.com/support`
- [ ] **No in-app purchases** attached to this version
- [ ] Pricing: **Free**

## 3. Copy & metadata (paste from repo)

| Field | Source file |
|-------|-------------|
| Name, subtitle, description, keywords | `Distribution/AppStoreConnect/metadata.json` |
| Submission JSON (API script) | `Distribution/AppStoreConnect/submission-response.json` |
| Export compliance answers | `Distribution/AppStoreConnect/export-compliance-responses.md` |
| TestFlight notes | `Distribution/TestFlight/release-notes-1.0.0.md` |
| Review notes | `Distribution/AppStoreConnect/review-notes.txt` |
| Resolution Center reply (Desktop) | `~/Desktop/PsychosocialAnalytics-AppStoreReviewReply-May30-2026.txt` |
| Screenshots | `./scripts/capture-distribution-screenshots.sh` |
| Upload steps | `Distribution/UPLOAD_TO_APP_STORE.md` |

## 4. Screenshots & preview

- [ ] 6.7" iPhone screenshots (required)
- [ ] 13" iPad screenshots (required for iPad support)
- [ ] Screenshots must **not** show Payments, Apple Pay, or Restore Purchases

## 5. Build & upload

```bash
xcodegen generate
./scripts/run-all-tests.sh
# Xcode: Product → Archive → Distribute → App Store Connect (build 4)
```

## 6. App Review information

- [ ] Sign-in required: **Yes**
- [ ] Demo: `admin@psychosocialanalytics.com` / `admin123`
- [ ] Notes: free app; no payments; see `review-notes.txt`
- [ ] Paste Resolution Center reply from Desktop copy if Apple asked about IAP/metadata

## 7. Submit

```bash
python3 scripts/appstore_complete_submission.py --fix-requirements
python3 scripts/appstore_complete_submission.py --all-screenshots
# After build 4 is processed in ASC:
python3 scripts/appstore_complete_submission.py --submit-only
```

## CI/CD

GitHub Actions on `main`, `develop`, and `ios/**`: unit tests, UI tests, distribution file checks.
