#!/usr/bin/env bash
# Bundles distribution materials for App Store submission upload.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/submission-pack"
VERSION="${1:-1.0.0}"

rm -rf "$OUT"
mkdir -p "$OUT/AppStoreConnect" "$OUT/TestFlight" "$OUT/screenshots"

cp "$ROOT/Distribution/AppStoreConnect/"* "$OUT/AppStoreConnect/" 2>/dev/null || true
cp "$ROOT/Distribution/TestFlight/release-notes-${VERSION}.md" "$OUT/TestFlight/" 2>/dev/null || \
  cp "$ROOT/Distribution/TestFlight/"*.md "$OUT/TestFlight/" 2>/dev/null || true
cp "$ROOT/Distribution/SUBMISSION_CHECKLIST.md" "$OUT/"
cp "$ROOT/Distribution/UPLOAD_TO_APP_STORE.md" "$OUT/"
cp "$ROOT/DISTRIBUTION.md" "$OUT/"
cp "$ROOT/CONFIGURATION.md" "$OUT/"
cp "$ROOT/App/PsychosocialAnalyticsApp/ExportOptions.plist" "$OUT/"
cp "$ROOT/App/PsychosocialAnalyticsApp/PrivacyInfo.xcprivacy" "$OUT/"

ZIP="$ROOT/build/PsychosocialAnalytics-submission-${VERSION}.zip"
(cd "$ROOT/build" && zip -r "$ZIP" "submission-pack" -x "*.DS_Store")

echo "Submission pack: $OUT"
echo "Zip archive: $ZIP"
