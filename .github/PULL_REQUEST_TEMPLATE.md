## Summary

<!-- What does this PR change and why? -->

## Test plan

- [ ] `xcodegen generate` succeeds
- [ ] `xcodebuild test -scheme PsychosocialAnalytics -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:PsychosocialAnalyticsTests CODE_SIGNING_ALLOWED=NO` passes locally
- [ ] CI workflow passes on this branch

## Distribution impact

- [ ] No App Store metadata changes required
- [ ] Version/build bumped in `project.yml` (if shipping)
