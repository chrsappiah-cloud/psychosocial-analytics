#!/usr/bin/env bash
# Resize iPad screenshots to App Store 13" iPad Pro required 2064×2752.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/Distribution/screenshots/ipad"
DEST="$ROOT/Distribution/screenshots/ipad/appstore-ready"
W=2064
H=2752

mkdir -p "$DEST"
shopt -s nullglob

for f in "$SRC"/*.png; do
  base=$(basename "$f")
  sips -z "$H" "$W" "$f" --out "$DEST/$base" >/dev/null
  echo "  $base -> $(sips -g pixelWidth -g pixelHeight "$DEST/$base" 2>/dev/null | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"x"h}')"
done

echo "iPad App Store-ready: $DEST (${W}x${H})"
