# Test fixtures

Static assets for unit and integration tests. Load via `FixtureLoader` in `Tests/PsychosocialAnalyticsTests/Support/TestSupport.swift`.

## Layout

| Path | Purpose |
|------|---------|
| `JSON/` | API response payloads for backend and middleware tests |
| `Profiles/` | Sample user profiles for auth and access-control tests |

## Conventions

- Keep fixtures small and focused on one behavior.
- Prefer JSON files over inline strings when a payload is reused or represents an API contract.
- Name files by scenario: `fetch-assessments-empty.json`, not `response1.json`.
- When adding a new API endpoint test, add or extend a matching fixture here first.

## Usage

```swift
let data = try FixtureLoader.data(named: "fetch-assessments-empty", subdirectory: "JSON")
let profile = try FixtureLoader.decode(AppUserProfile.self, named: "clinician-active", subdirectory: "Profiles")
```
