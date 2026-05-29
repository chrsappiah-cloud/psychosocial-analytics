# App Store Connect — Export Compliance Responses

Use these answers when submitting **Psychosocial Analytics** build `1.0.0 (4)`.

## Does your app use encryption?

**No** — Select: *App uses encryption but is exempt*

The app does not implement proprietary cryptography. Networking uses Apple’s standard HTTPS/TLS APIs only.

## Info.plist confirmation

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

## Privacy nutrition (summary)

| Data type | Collected | Linked to user | Tracking |
|-----------|-----------|----------------|----------|
| Health / clinical notes (user-entered) | Yes (on device) | No | No |
| Contact info (user-entered) | Yes (on device) | No | No |
| Diagnostics | No | — | — |

Full privacy policy URL: `https://www.psychosocialanalytics.com/privacy`

## App Review notes (paste into Resolution Center if asked)

> Build 4 removes all in-app purchases and Apple Pay. Psychosocial Analytics is a free clinical documentation tool for social workers. Assessment data is stored on-device. The AI draft feature returns simulated narrative text for clinician review; no PHI is sent to third-party AI in this build. Demo: Public tab — any email; Admin — admin@psychosocialanalytics.com / admin123.

Full reply: `~/Desktop/PsychosocialAnalytics-AppStoreReviewReply-May30-2026.txt`
