# App Store Connect — form responses (copy/paste)

**App ID:** `6768490648`  
**In-flight version:** https://appstoreconnect.apple.com/apps/6768490648/distribution/ios/version/inflight  
**Bundle ID:** `wcs.Psychosocial--Analytics`  
**Version / build:** `1.0.0` / `3`

Machine-readable copy: `submission-response.json`  
Screenshots folder: `Distribution/screenshots/` (run `./scripts/capture-distribution-screenshots.sh`)

---

## 1. Version information

| Form field | Response |
|------------|----------|
| **Version** | `1.0.0` |
| **Copyright** | `© 2026 World Class Services` |

### What's New in This Version

```
Initial release of Psychosocial Analytics for iOS.

• Structured psychosocial assessments with section-based clinical workflow
• Upload hub: files, media, pasted text, and HTTPS URL imports
• New client intake with secure sync when configured
• Caseload dashboard, client search, insights, and reports
• AI-assisted report drafts (review before clinical use)
• Public / Administrator login with role-based access control
• Admin panel: user management, subscription control, storage monitoring
• Apple In-App Purchases (StoreKit 2): Professional / Enterprise subscriptions
• Apple Pay integration for one-time report purchases and consultation fees
• Dark, accessible interface for field use
```

---

## 2. App Information (English U.S.)

| Form field | Max | Response |
|------------|-----|----------|
| **Name** | — | Psychosocial Analytics |
| **Subtitle** | 30 | Caseload & assessments |
| **Promotional Text** | 170 | Document psychosocial assessments, track caseloads, and generate AI-assisted report drafts—built for social work teams. |

### Description

```
Psychosocial Analytics helps social workers and clinical teams capture structured psychosocial assessments, manage client caseloads, upload clinical media, and prepare report drafts with AI assistance.

Key features:
• Structured psychosocial assessment sections aligned to clinical workflows
• Upload hub: files, photos, videos, audio, text, and HTTPS URL imports
• New client intake with secure cloud sync
• Client search, caseload dashboard, and reporting views
• Public / Administrator login with role-based access control
• Admin panel: manage users, tiers, account status, and storage backends
• Apple In-App Purchases: Professional & Enterprise subscriptions via StoreKit 2
• Apple Pay integration for one-time report purchases and consultation fees
• Supabase primary storage with iCloud and Cloudflare backups
• Dark, accessible interface for field use

Review all AI-generated content before signing or exporting clinical documents. Configure Supabase credentials for production sync.
```

| Form field | Response |
|------------|----------|
| **Keywords** | psychosocial,social work,assessment,caseload,clinical,mental health,reports,apple pay,admin panel |
| **Support URL** | https://www.psychosocialanalytics.com/support |
| **Marketing URL** | https://www.psychosocialanalytics.com |
| **Privacy Policy URL** | https://www.psychosocialanalytics.com/privacy |

---

## 3. Screenshots — iPhone 6.7" Display

Upload in this order (files in `Distribution/screenshots/`):

| Slot | File | Screen |
|------|------|--------|
| 1 | `01-login.png` | Public Access login |
| 2 | `02-home.png` | Home dashboard |
| 3 | `03-upload.png` | Upload — Files & Media |
| 4 | `04-upload-newclient.png` | Upload — New Client |
| 5 | `05-assess.png` | Assessments list |
| 6 | `06-clients.png` | Clients |
| 7 | `07-insights.png` | Insights metrics |
| 8 | `08-reports.png` | Reports |
| 9 | `09-settings.png` | Settings & subscriptions |
| 10 | `10-admin-overview.png` | Admin — Overview |

**Resolution:** 1290 × 2796 px (iPhone 15/16/17 Pro Max simulator captures are correct for 6.7" group).

---

## 4. App Review Information

| Form field | Response |
|------------|----------|
| **Sign-in required** | Yes |
| **Username** | `admin@psychosocialanalytics.com` |
| **Password** | `admin123` |
| **Notes** | See `review-notes.txt` (full text below) |

```
Psychosocial Analytics — App Review Notes (v1.0.0)

- Public login: enter any email to sign in as a clinician user.
- Administrator login: admin@psychosocialanalytics.com / admin123 for full admin panel.
- Admin panel includes Overview, Access Control, Payments, Storage, and Apple Pay sections.
- Apple Pay uses PassKit with merchant ID merchant.com.wcs.psychosocialanalytics.
- Upload tab supports files, photos, video, text, and HTTPS URL imports.
- AI drafts are simulated; no PHI sent to third-party AI.
- Subscriptions use StoreKit 2 (Professional / Enterprise).
- Export compliance: standard HTTPS only (ITSAppUsesNonExemptEncryption = false).

Contact: support@psychosocialanalytics.com
```

| Form field | Response |
|------------|----------|
| **First name** | *(your name)* |
| **Last name** | *(your name)* |
| **Phone** | *(your phone)* |
| **Email** | support@psychosocialanalytics.com |

---

## 5. Export compliance (per build)

| Question | Answer |
|----------|--------|
| Does your app use encryption? | **Yes** |
| Is it exempt? | **Yes** — standard encryption only |
| Uses proprietary/non-exempt encryption? | **No** |
| Documentation required? | **No** (`ITSAppUsesNonExemptEncryption` = false) |

---

## 6. App Privacy questionnaire

| Question | Answer |
|----------|--------|
| Do you or third-party partners use data for tracking? | **No** |
| Data collected — Name | Yes · App Functionality · Not linked to identity |
| Data collected — Health & Fitness | Yes · App Functionality · Not linked to identity |
| Data collected — Other User Content | Yes · App Functionality · Not linked to identity |
| Data collected — Email Address | Yes · App Functionality · Linked to identity |

Detail mapping: `privacy-nutrition-labels.json`

---

## 7. Age rating (questionnaire highlights)

| Topic | Answer |
|-------|--------|
| Cartoon / fantasy violence | None |
| Realistic violence | None |
| Sexual content | None |
| Profanity | None |
| Medical / treatment information | **Infrequent/Mild** (clinical documentation) |
| Gambling | None |
| Unrestricted web access | No |
| Made for kids | No |

**Expected rating:** 4+

---

## 8. In-App Purchases (attach to version)

| Product ID | Type | Display name |
|------------|------|--------------|
| `com.wcs.psychosocial.pro.monthly` | Auto-renewable subscription | Professional Monthly |
| `com.wcs.psychosocial.pro.yearly` | Auto-renewable subscription | Professional Yearly |
| `com.wcs.psychosocial.enterprise.monthly` | Auto-renewable subscription | Enterprise Monthly |
| `com.wcs.psychosocial.report` | Consumable | Single Report (Apple Pay) |
| `com.wcs.psychosocial.consultation` | Consumable | Consultation Fee (Apple Pay) |

---

## 9. General app metadata

| Field | Value |
|-------|-------|
| Primary category | Medical |
| Secondary category | Education |
| Content rights | Does not contain third-party content |
| Price | Free (IAP for subscriptions) |
| Availability | All territories |
