# Psychosocial Analytics

iOS application for psychosocial assessments, client caseload management, multi-format uploads, and AI-assisted clinical report drafts.

## Features

- Structured psychosocial assessment workflows
- Client caseload dashboard and search
- **Upload hub**: files, photo/video library, text notes, external URL import
- **New client intake** with Supabase-primary storage
- Role-based access (clinician / administrator) with configurable access tiers
- Storage: **Supabase** (primary), **CloudKit/iCloud** and **Cloudflare** backups
- Dark, accessible UI

## Requirements

- Xcode 16+
- iOS 17.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation

## Quick start

```bash
brew install xcodegen
cd "Psychosocial Analytics"
xcodegen generate
open PsychosocialAnalytics.xcodeproj
```

Run on simulator: **⌘R** (scheme: `PsychosocialAnalytics`).

## Configuration

See [CONFIGURATION.md](CONFIGURATION.md) for Supabase, Cloudflare, and iCloud setup.

## Testing

```bash
xcodebuild test -scheme PsychosocialAnalytics \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PsychosocialAnalyticsTests \
  CODE_SIGNING_ALLOWED=NO
```

Or run the full script:

```bash
./scripts/run-all-tests.sh
```

## Distribution

See [DISTRIBUTION.md](DISTRIBUTION.md) and [Distribution/SUBMISSION_CHECKLIST.md](Distribution/SUBMISSION_CHECKLIST.md).

## CI/CD

| Workflow | Trigger | Actions |
|----------|---------|---------|
| [CI](.github/workflows/ci.yml) | Push/PR to `main`, `develop` | Build + unit tests |
| [Release](.github/workflows/release.yml) | Tags `v*.*.*` | Release build validation + artifact upload |

## License

Proprietary — WCS. All rights reserved.
