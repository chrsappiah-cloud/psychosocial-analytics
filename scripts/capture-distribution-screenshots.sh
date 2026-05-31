#!/usr/bin/env bash
# Captures App Store Connect screenshots (6.7") — core app in use (no login splash).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/Distribution/screenshots"
DEVICE="${SIMULATOR_DEVICE:-iPhone 17 Pro Max}"
BUNDLE="wcs.Psychosocial--Analytics"

mkdir -p "$DEST" "$DEST/appstore-ready"
cd "$ROOT"

xcodegen generate >/dev/null

echo "Building for simulator..."
xcodebuild -scheme PsychosocialAnalytics \
  -destination "platform=iOS Simulator,name=${DEVICE}" \
  -configuration Debug build CODE_SIGNING_ALLOWED=NO >/dev/null

APP=$(find ~/Library/Developer/Xcode/DerivedData -path "*Debug-iphonesimulator/PsychosocialAnalyticsApp.app" -print -quit)
if [ -z "$APP" ]; then
  echo "Could not find built .app"
  exit 1
fi

xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl uninstall booted "$BUNDLE" 2>/dev/null || true
xcrun simctl install booted "$APP"

capture() {
  local mode="$1"
  local file="$2"
  xcrun simctl terminate booted "$BUNDLE" 2>/dev/null || true
  sleep 1
  xcrun simctl launch booted "$BUNDLE" "--screenshot=${mode}"
  sleep 3
  xcrun simctl io booted screenshot "$DEST/${file}"
  sips -z 2796 1290 "$DEST/${file}" --out "$DEST/appstore-ready/${file}" >/dev/null
  echo "  ✓ ${file} (1290×2796)"
}

echo "Capturing iPhone 6.7\" screenshots (app in use — Guideline 2.3.3)..."
capture home              "01-home.png"
capture upload            "02-upload.png"
capture upload-newclient  "03-upload-newclient.png"
capture assess            "04-assess.png"
capture clients           "05-clients.png"
capture insights          "06-insights.png"
capture reports           "07-reports.png"
capture settings-account  "08-settings-account.png"
capture admin-overview    "09-admin-overview.png"
capture admin-storage     "10-admin-storage.png"

echo ""
echo "Screenshots ready: $DEST/appstore-ready"
ls -la "$DEST/appstore-ready"/*.png 2>/dev/null | awk '{print "  " $NF}'
