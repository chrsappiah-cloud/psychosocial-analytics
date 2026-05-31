#!/usr/bin/env bash
# Parses xcodebuild xcresult coverage and fails if PsychosocialAnalytics is below threshold.
set -euo pipefail

RESULT_BUNDLE="${1:-TestResults-Unit.xcresult}"
MIN_COVERAGE="${MIN_LINE_COVERAGE:-12}"

if [ ! -d "$RESULT_BUNDLE" ]; then
  echo "Coverage bundle not found: $RESULT_BUNDLE"
  exit 1
fi

REPORT="$(xcrun xccov view --report "$RESULT_BUNDLE" 2>/dev/null || true)"
if [ -z "$REPORT" ]; then
  echo "Could not read coverage report from $RESULT_BUNDLE"
  exit 1
fi

TARGET_LINE="$(echo "$REPORT" | awk '/^PsychosocialAnalytics[[:space:]]/ {print $2; exit}')"
if [ -z "$TARGET_LINE" ]; then
  echo "PsychosocialAnalytics target not found in coverage report."
  echo "$REPORT" | head -20
  exit 1
fi

COVERAGE_NUM="$(echo "$TARGET_LINE" | tr -d '%')"
echo "PsychosocialAnalytics line coverage: ${COVERAGE_NUM}% (minimum ${MIN_COVERAGE}%)"

awk -v actual="$COVERAGE_NUM" -v min="$MIN_COVERAGE" 'BEGIN {
  if (actual + 0 < min + 0) {
    printf("Coverage %.2f%% is below minimum %.2f%%\n", actual, min);
    exit 1;
  }
}'

echo "Coverage gate passed."
