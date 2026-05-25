#!/usr/bin/env bash
# Captures 6.7" screenshots via UI tests and copies from xcresult to Distribution/screenshots/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/Distribution/screenshots"
RESULT="$ROOT/build/ScreenshotTest.xcresult"
DEVICE="${SIMULATOR_DEVICE:-iPhone 17 Pro Max}"

mkdir -p "$DEST" "$ROOT/build"
rm -rf "$RESULT"

cd "$ROOT"
xcodebuild test \
  -scheme PsychosocialAnalytics \
  -destination "platform=iOS Simulator,name=${DEVICE}" \
  -only-testing:PsychosocialAnalyticsUITests/AppStoreScreenshotUITests \
  -resultBundlePath "$RESULT" \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tail -20

# Extract PNG attachments named 01-* … 10-*
python3 - "$RESULT" "$DEST" <<'PY'
import sys, json, shutil
from pathlib import Path

result = Path(sys.argv[1])
dest = Path(sys.argv[2])
dest.mkdir(parents=True, exist_ok=True)

actions = result / "Actions.json"
if not actions.exists():
    sys.exit("No Actions.json in xcresult")

data = json.loads(actions.read_text())
refs = []

def walk(obj):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k == "filename" and isinstance(v, str) and v.endswith(".png"):
                refs.append(v)
            walk(v)
    elif isinstance(obj, list):
        for x in obj:
            walk(x)

walk(data)

# XCTest stores attachments under Data/
data_dir = result / "Data"
found = sorted(data_dir.rglob("*.png")) if data_dir.exists() else []
if not found:
    print("No PNG attachments found. Open xcresult in Xcode: Report Navigator -> attachments.")
    sys.exit(1)

names = [
    "01-login", "02-home", "03-upload", "04-assess",
    "05-clients", "06-insights", "07-settings",
    "08-admin-overview", "09-admin-payments", "10-admin-apple-pay"
]
for i, src in enumerate(found[:len(names)]):
    out = dest / f"{names[i]}.png"
    shutil.copy2(src, out)
    print(f"Wrote {out}")

print(f"\nUpload these PNGs to App Store Connect (6.7\" display):")
print(f"  {dest}")
PY
