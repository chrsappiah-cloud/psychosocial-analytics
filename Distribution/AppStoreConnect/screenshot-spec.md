# App Store screenshot spec — v1.0.0 (build 5)

6.7" iPhone (1290×2796). Capture with `./scripts/capture-distribution-screenshots.sh`.

**Guideline 2.3.3:** Do not lead with login/splash. Majority of shots must show core app in use.

| # | File | Screen |
|---|------|--------|
| 1 | `01-home.png` | Dashboard / caseload |
| 2 | `02-upload.png` | Upload hub |
| 3 | `03-upload-newclient.png` | Upload → New Client |
| 4 | `04-assess.png` | Assessments |
| 5 | `05-clients.png` | Clients |
| 6 | `06-insights.png` | Insights |
| 7 | `07-reports.png` | Reports |
| 8 | `08-settings-account.png` | Settings → Account (Delete Account visible) |
| 9 | `09-admin-overview.png` | Admin → Overview |
| 10 | `10-admin-storage.png` | Admin → Storage |

Do not use blank images. Do not show Payments, Apple Pay, or subscriptions.

iPad 13": `scripts/capture-ipad-screenshots.sh` → home, upload, clients, admin (no login).
