# App Store Connect — in-flight version 1.0.0

**App:** Psychosocial Analytics  
**App Store Connect ID:** `6768490648`  
**Version page:** https://appstoreconnect.apple.com/apps/6768490648/distribution/ios/version/inflight  
**Bundle ID:** `wcs.Psychosocial--Analytics`  
**Marketing version / build:** `1.0.0` / `4`

Use this file to copy fields into the in-flight version. This build is a **free app** with **no in-app purchases or Apple Pay**.

---

## Version information

| Field | Value |
|-------|-------|
| Version | `1.0.0` |
| Copyright | `© 2026 World Class Services` |

### What's New in This Version

```
This update removes all in-app purchases and Apple Pay. Psychosocial Analytics is now a free app.

• Structured psychosocial assessments with section-based clinical workflow
• Upload hub: files, media, pasted text, and HTTPS URL imports
• New client intake with secure sync when configured
• Caseload dashboard, client search, insights, and reports
• AI-assisted report drafts (review before clinical use)
• Public / Administrator login with role-based access control
• Admin panel: user access control and storage monitoring (no payments)
• Dark, accessible interface for field use
```

---

## App Information (if prompted on this version)

| Field | Paste value |
|-------|-------------|
| **Subtitle** (30 chars max) | Caseload & assessments |
| **Promotional Text** (170 chars) | Document psychosocial assessments, track caseloads, and generate AI-assisted report drafts—built for social work teams. Free app; no in-app purchases. |

### Description

```
Psychosocial Analytics helps social workers and clinical teams capture structured psychosocial assessments, manage client caseloads, upload clinical media, and prepare report drafts with AI assistance.

Key features:
• Structured psychosocial assessment sections aligned to clinical workflows
• Upload hub: files, photos, videos, audio, text, and HTTPS URL imports
• New client intake with secure cloud sync
• Client search, caseload dashboard, and reporting views
• Public / Administrator login with role-based access control
• Admin panel: manage users, account status, and storage backends
• Supabase primary storage with iCloud and Cloudflare backups
• Dark, accessible interface for field use

This app is free and does not offer in-app purchases or Apple Pay.

Review all AI-generated content before signing or exporting clinical documents. Configure Supabase credentials for production sync.
```

### Keywords (100 chars total, comma-separated, no spaces after commas)

```
psychosocial,social work,assessment,caseload,clinical,mental health,reports,admin panel
```

### URLs

| Field | URL |
|-------|-----|
| Support URL | https://www.psychosocialanalytics.com/support |
| Marketing URL | https://www.psychosocialanalytics.com |
| Privacy Policy URL | https://www.psychosocialanalytics.com/privacy |

---

## Build

1. **TestFlight** → wait for build `1.0.0 (4)` to finish processing.
2. On the in-flight version page → **Build** → **+** → select that build.

---

## App Review Information

| Field | Value |
|-------|-------|
| Sign-in required? | **Yes** — Public or Administrator login |
| User name | *(any email for Public, or admin@psychosocialanalytics.com for Admin)* |
| Password | *(leave blank for Public; admin123 for Admin)* |
| Contact email | support@psychosocialanalytics.com |

### Notes

```
Psychosocial Analytics — App Review Notes (v1.0.0, build 4)

IAP REMOVED: No in-app purchases, Apple Pay, or Restore Purchases. App is free.

ACCOUNT DELETION: Settings → Account → Delete Account (two-step confirmation).

- Public login: enter any email to sign in as a clinician user.
- Administrator login: admin@psychosocialanalytics.com / admin123 for full admin panel.
- Admin panel includes Overview, Access Control, and Storage only.
- Upload tab supports files, photos, video, text, and HTTPS URL imports.
- AI drafts are simulated; no PHI sent to third-party AI.
- Export compliance: standard HTTPS only (ITSAppUsesNonExemptEncryption = false).

Contact: support@psychosocialanalytics.com
```

---

## Export compliance (when attaching build)

| Question | Answer |
|----------|--------|
| Is your app designed to use cryptography or does it contain cryptography? | **Yes** (HTTPS only) |
| Is it exempt? | **Yes** — only standard Apple encryption |
| Documentation | Not required — `ITSAppUsesNonExemptEncryption` = **false** in Info.plist |

---

## In-App Purchases

**None.** Remove any IAP products from this version before submitting.

---

## Screenshots (6.7" Display)

Generate locally:

```bash
./scripts/capture-distribution-screenshots.sh
```

Upload these files from `Distribution/screenshots/` in order:

| # | File |
|---|------|
| 1 | `01-login.png` |
| 2 | `02-home.png` |
| 3 | `03-upload.png` |
| 4 | `04-upload-newclient.png` |
| 5 | `05-assess.png` |
| 6 | `06-clients.png` |
| 7 | `07-insights.png` |
| 8 | `08-reports.png` |
| 9 | `09-settings.png` |
| 10 | `10-admin-overview.png` |

Full form field mapping: `FORM_RESPONSES.md`

---

## Submit checklist (this page)

- [ ] All localized metadata saved
- [ ] Screenshots uploaded for 6.7" (and iPad if universal)
- [ ] Build `1.0.0 (4)` selected
- [ ] Export compliance answered
- [ ] **No** IAP products linked to version
- [ ] App Privacy complete
- [ ] Age rating / category: Medical (+ Education secondary)
- [ ] **Add for Review** → Submit
