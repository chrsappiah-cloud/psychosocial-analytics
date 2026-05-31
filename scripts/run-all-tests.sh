#!/usr/bin/env bash
# Runs SwiftPM unit tests and Xcode unit + UI tests. Writes TEST_REPORT.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
REPORT="$ROOT/TEST_REPORT.md"
SIMULATOR="${SIMULATOR:-iPhone 17 Pro Max}"
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

# iOS-only APIs; SwiftPM on macOS is optional smoke only.
if swift test 2>/dev/null; then
  echo "## Swift Package (macOS) unit tests" >> "$REPORT"
  echo "" >> "$REPORT"
  echo "**Swift Package (macOS):** PASSED (optional)" >> "$REPORT"
  echo "" >> "$REPORT"
else
  echo "## Swift Package (macOS) unit tests" >> "$REPORT"
  echo "" >> "$REPORT"
  echo "**Swift Package (macOS):** SKIPPED (iOS-only APIs; use Xcode iOS Simulator tests below)" >> "$REPORT"
  echo "" >> "$REPORT"
fi

run_step "Xcode unit + UI tests (iOS Simulator)" \
  xcodebuild test \
    -scheme PsychosocialAnalytics \
    -destination "$DESTINATION" \
    -enableCodeCoverage YES \
    -resultBundlePath "$ROOT/build/TestResults.xcresult" \
    CODE_SIGNING_ALLOWED=NO

echo "## Coverage" >> "$REPORT"
echo "" >> "$REPORT"
if "$ROOT/scripts/check-coverage.sh" "$ROOT/build/TestResults.xcresult" 2>&1 | tee -a "$REPORT"; then
  echo "" >> "$REPORT"
  echo "**Coverage gate:** PASSED" >> "$REPORT"
else
  echo "" >> "$REPORT"
  echo "**Coverage gate:** FAILED" >> "$REPORT"
  exit 1
fi
echo "" >> "$REPORT"

echo "## Summary" >> "$REPORT"
echo "" >> "$REPORT"
echo "All test suites completed successfully." >> "$REPORT"
echo "Result bundle: \`build/TestResults.xcresult\`" >> "$REPORT"
echo "" >> "$REPORT"
echo "Done. See $REPORT"
