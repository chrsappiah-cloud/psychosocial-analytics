#!/usr/bin/env bash
# Resizes iPhone 6.7" screenshots to App Store required 1290×2796.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/Distribution/screenshots"
READY="$DEST/appstore-ready"
W=1290
H=2796

mkdir -p "$READY"
shopt -s nullglob

for src in "$DEST"/*.png; do
  base=$(basename "$src")
  # Skip already-correct files in ready folder
  out="$READY/$base"
  # sips -z takes height then width
  sips -z "$H" "$W" "$src" --out "$out" >/dev/null
  got=$(sips -g pixelWidth -g pixelHeight "$out" 2>/dev/null | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w,h}')
  echo "  $base -> $got"
done

echo ""
echo "App Store-ready screenshots: $READY"
echo "Required: ${W}x${H} (iPhone 6.7\" Display)"
