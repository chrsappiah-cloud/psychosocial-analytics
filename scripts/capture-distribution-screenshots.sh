#!/usr/bin/env bash
# Captures App Store Connect screenshots (6.7") via simulator launch modes.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/Distribution/screenshots"
DEVICE="${SIMULATOR_DEVICE:-iPhone 17 Pro Max}"
BUNDLE="wcs.Psychosocial--Analytics"

mkdir -p "$DEST" "$DEST/ipad"
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
  if [ "$mode" = "login" ]; then
    xcrun simctl launch booted "$BUNDLE"
  else
    xcrun simctl launch booted "$BUNDLE" "--screenshot=${mode}"
  fi
  sleep 3
  xcrun simctl io booted screenshot "$DEST/${file}"
  echo "  ✓ ${file}"
}

echo "Capturing iPhone 6.7\" screenshots..."
capture login           "01-login.png"
capture home            "02-home.png"
capture upload          "03-upload.png"
capture upload-newclient "04-upload-newclient.png"
capture assess          "05-assess.png"
capture clients         "06-clients.png"
capture insights        "07-insights.png"
capture reports         "08-reports.png"
capture settings        "09-settings.png"
capture admin-overview  "10-admin-overview.png"
capture admin-payments  "11-admin-payments.png"
capture admin-applepay  "12-admin-applepay.png"

# Symlinks for submission-response.json legacy names
ln -sf 03-upload.png "$DEST/03-upload-files.png" 2>/dev/null || cp "$DEST/03-upload.png" "$DEST/03-upload-files.png"
ln -sf 05-assess.png "$DEST/04-assess.png" 2>/dev/null || true

echo ""
echo "Screenshots ready: $DEST"
ls -la "$DEST"/*.png 2>/dev/null | awk '{print "  " $NF}'
