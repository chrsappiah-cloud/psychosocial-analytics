#!/usr/bin/env bash
# Fix all App Store Connect "Unable to Add for Review" blockers (API + iPad screenshots).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== Fixing submission requirements ==="
python3 scripts/appstore_complete_submission.py --fix-requirements

echo ""
echo "=== Uploading iPhone + 13-inch iPad screenshots ==="
python3 scripts/appstore_complete_submission.py --all-screenshots

echo ""
echo "=== Done ==="
echo "Refresh: https://appstoreconnect.apple.com/apps/6768490648/distribution/ios/version/inflight"
echo ""
echo "If 'App Privacy' still warns: App Store Connect → App Privacy → Privacy Policy"
echo "  URL: https://www.psychosocialanalytics.com/privacy → Save → Publish"
