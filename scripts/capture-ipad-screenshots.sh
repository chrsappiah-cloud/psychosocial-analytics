#!/usr/bin/env bash
# Capture 13-inch iPad screenshots for App Store Connect (APP_IPAD_PRO_3GEN_129).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/Distribution/screenshots/ipad"
DEVICE="${IPAD_SIMULATOR:-ScholarsGallery iPad 13}"
BUNDLE="wcs.Psychosocial--Analytics"

mkdir -p "$DEST/appstore-ready"
cd "$ROOT"
xcodegen generate >/dev/null

echo "Building for iPad simulator..."
xcodebuild -scheme PsychosocialAnalytics \
  -destination "platform=iOS Simulator,name=${DEVICE}" \
  -configuration Debug build CODE_SIGNING_ALLOWED=NO >/dev/null

APP=$(find ~/Library/Developer/Xcode/DerivedData -path "*Debug-iphonesimulator/PsychosocialAnalyticsApp.app" -print -quit)
test -n "$APP" || { echo "Build failed"; exit 1; }

xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl uninstall booted "$BUNDLE" 2>/dev/null || true
xcrun simctl install booted "$APP"

capture() {
  local mode="$1"
  local file="$2"
  xcrun simctl terminate booted "$BUNDLE" 2>/dev/null || true
  sleep 1
  if [ "$mode" = "login" ]; then
    xcrun simctl launch booted "$BUNDLE"
  else
    xcrun simctl launch booted "$BUNDLE" "--screenshot=${mode}"
  fi
  sleep 3
  xcrun simctl io booted screenshot "$DEST/${file}"
  sips -z 2752 2064 "$DEST/${file}" --out "$DEST/appstore-ready/${file}" >/dev/null
  echo "  ✓ ${file} (2064×2752)"
}

echo "Capturing 13\" iPad screenshots on: ${DEVICE}"
capture home            "01-home.png"
capture upload          "02-upload.png"
capture clients         "03-clients.png"
capture admin-overview  "04-admin.png"

echo "Done: $DEST/appstore-ready/"
