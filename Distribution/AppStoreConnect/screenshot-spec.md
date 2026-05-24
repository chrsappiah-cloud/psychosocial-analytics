# Screenshot specification — App Store Connect

Capture on **iPhone 15 Pro Max** or **iPhone 16 Pro Max** simulator (6.7" display group).

| # | Screen | Tab / action | Caption (optional) |
|---|--------|--------------|-------------------|
| 1 | Home dashboard | Home | Caseload at a glance |
| 2 | Upload — Files & Media | Upload → Files | Upload text, audio, video, and documents |
| 3 | Upload — New Client | Upload → New Client | Register new clients quickly |
| 4 | Upload — URL Import | Upload → URL Import | Import files from HTTPS links |
| 5 | Assessments list | Assess | Structured psychosocial assessments |
| 6 | Assessment detail + AI | Assess → open → AI section | AI-assisted report drafts |
| 7 | Settings + subscription | Settings | Plans and administrator controls |

## iPad (if submitting universal)

Use **13" iPad Pro** simulator: Home, Upload hub, Clients list.

## Export

```bash
# Simulator screenshot: File → Save Screen Shot (⌘S)
# Or:
xcrun simctl io booted screenshot Distribution/screenshots/01-home.png
```

Store PNGs under `Distribution/screenshots/` (gitignored if large).
