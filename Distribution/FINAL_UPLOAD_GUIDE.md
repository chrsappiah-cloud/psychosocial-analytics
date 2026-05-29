# Final upload guide — v1.0.0 (build 4)

Addresses App Review submission `b14ba558-cfc8-4d90-878d-3234594d2a7d`.

## Build 4 changes

- All in-app purchases and Apple Pay removed (free app)
- Account deletion: Settings → Account → Delete Account
- New non-blank screenshots

## Steps

1. `xcodegen generate` && `./scripts/run-all-tests.sh`
2. Archive build **4** → App Store Connect
3. App Store Connect → remove all IAP products from this version
4. `./scripts/fix-submission-blockers.sh` (metadata + screenshots)
5. Paste Resolution Center reply from `~/Desktop/PsychosocialAnalytics-AppStoreReviewReply-May30-2026.txt`
6. Attach account-deletion screen recording (physical iPhone) in App Review Information
7. `python3 scripts/appstore_complete_submission.py --submit-only` after build processes

## Guideline 5.1.1(ix) — organization account

Account Holder must contact Apple Developer Support to convert to an **Organization** account and update seller name to **World Class Services**. This is not fixable in the binary.
