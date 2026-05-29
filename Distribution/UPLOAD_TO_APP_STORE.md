# Upload Psychosocial Analytics to App Store Connect

Build **1.0.0 (4)** — free app, **no in-app purchases**.

## Prerequisites

- [ ] Apple Developer account with App Store Connect access
- [ ] API key at `~/.appstoreconnect/private_keys/AuthKey_4B8M4ZHLMF.p8` (for automation script)
- [ ] Xcode archive uploaded as build **4**
- [ ] In-App Purchase products **removed** from the version in App Store Connect

## Quick automation

```bash
cd "Psychosocial Analytics"
./scripts/fix-submission-blockers.sh
# After build 4 appears in ASC:
python3 scripts/appstore_complete_submission.py --submit-only
```

## Manual checklist

| Step | Action |
|------|--------|
| 1 | Archive in Xcode → Distribute → App Store Connect |
| 2 | Select build **4** on the version |
| 3 | Paste metadata from `submission-response.json` or run full script |
| 4 | Upload screenshots (`scripts/capture-distribution-screenshots.sh`) |
| 5 | Review notes: `AppStoreConnect/review-notes.txt` |
| 6 | Resolution Center: paste `~/Desktop/PsychosocialAnalytics-AppStoreReviewReply-May30-2026.txt` if replying to IAP feedback |
| 7 | **Add for Review** → Submit |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Metadata mentions IAP | Re-run `appstore_complete_submission.py` after updating `submission-response.json` |
| IAP still on version | App Store Connect → version → In-App Purchases → remove all |
| Submit blocked | Attach non-expired build 4, complete App Privacy questionnaire |
