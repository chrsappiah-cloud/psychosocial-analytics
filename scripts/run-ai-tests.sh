#!/usr/bin/env bash
# Runs all AI generation tests (unit, integration, E2E, UI).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== Swift Package: AI test suites ==="
swift test --filter 'GenAIService|AIGeneration|AssessmentViewModelAI' 2>&1

echo ""
echo "=== Xcode: AI UI tests (Simulator) ==="
xcodebuild test \
  -scheme PsychosocialAnalytics \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:PsychosocialAnalyticsUITests/AIGenerationUITests \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tail -25

echo ""
echo "All AI generation tests finished."
