#!/usr/bin/env bash
# Runs SwiftPM unit tests and Xcode unit + UI tests. Writes TEST_REPORT.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
REPORT="$ROOT/TEST_REPORT.md"
SIMULATOR="${SIMULATOR:-iPhone 17}"
DESTINATION="platform=iOS Simulator,name=${SIMULATOR}"

echo "# Test Report — Psychosocial Analytics" > "$REPORT"
echo "" >> "$REPORT"
echo "Generated: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >> "$REPORT"
echo "" >> "$REPORT"

run_step() {
  local name="$1"
  shift
  echo "## $name" >> "$REPORT"
  echo "" >> "$REPORT"
  echo '```' >> "$REPORT"
  if "$@" 2>&1 | tee -a "$REPORT"; then
    echo '```' >> "$REPORT"
    echo "" >> "$REPORT"
    echo "**$name:** PASSED" >> "$REPORT"
  else
    echo '```' >> "$REPORT"
    echo "" >> "$REPORT"
    echo "**$name:** FAILED" >> "$REPORT"
    exit 1
  fi
  echo "" >> "$REPORT"
}

xcodegen generate >/dev/null 2>&1 || true

run_step "Swift Package (macOS) unit tests" swift test

run_step "Xcode unit + UI tests (iOS Simulator)" \
  xcodebuild test \
    -scheme PsychosocialAnalytics \
    -destination "$DESTINATION" \
    -resultBundlePath "$ROOT/build/TestResults.xcresult" \
    CODE_SIGNING_ALLOWED=NO

echo "## Summary" >> "$REPORT"
echo "" >> "$REPORT"
echo "All test suites completed successfully." >> "$REPORT"
echo "Result bundle: \`build/TestResults.xcresult\`" >> "$REPORT"
echo "" >> "$REPORT"
echo "Done. See $REPORT"
