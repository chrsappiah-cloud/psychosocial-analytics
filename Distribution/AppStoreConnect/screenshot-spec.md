# Screenshot specification — App Store Connect

Capture on **iPhone 15 Pro Max** or **iPhone 16 Pro Max** simulator (6.7" display group).

| # | Screen | Tab / action | Caption (optional) |
|---|--------|--------------|-------------------|
| 1 | Login screen | Launch → Public Access tab | Secure role-based sign-in |
| 2 | Home dashboard | Home | Caseload at a glance |
| 3 | Upload — Files & Media | Upload → Files | Upload text, audio, video, and documents |
| 4 | Upload — New Client | Upload → New Client | Register new clients quickly |
| 5 | Assessments list | Assess | Structured psychosocial assessments |
| 6 | Assessment detail + AI | Assess → open → AI section | AI-assisted report drafts |
| 7 | Settings + subscription | Settings | Plans and administrator controls |
| 8 | Admin panel — Overview | Admin (shield icon) | Administrator dashboard overview |
| 9 | Admin panel — Payments | Admin → Payments | Subscription & payment management |
| 10 | Admin panel — Apple Pay | Admin → Apple Pay | One-time purchases via Apple Pay |

## iPad (if submitting universal)

Use **13" iPad Pro** simulator: Home, Upload hub, Clients list, Admin panel.

## Export

```bash
# Simulator screenshot: File → Save Screen Shot (⌘S)
# Or:
xcrun simctl io booted screenshot Distribution/screenshots/01-home.png
```

Store PNGs under `Distribution/screenshots/` (gitignored if large).
