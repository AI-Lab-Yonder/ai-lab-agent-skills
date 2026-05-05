#!/usr/bin/env bash
# Stitch recordings/<slug>/frames/*.png into recordings/<slug>/<slug>.gif
# Usage: frames-to-gif.sh <slug> [fps] [width]
set -euo pipefail

slug="${1:?slug required}"
fps="${2:-4}"
width="${3:-720}"

base="recordings/$slug"
src="$base/frames"
out="$base/$slug.gif"
palette="$src/_palette.png"

if [[ ! -d "$src" ]]; then
  echo "No frames at $src" >&2; exit 1
fi
if ! ls "$src"/*.png >/dev/null 2>&1; then
  echo "No PNG frames in $src" >&2; exit 1
fi

if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -y -framerate "$fps" -i "$src/%03d.png" \
    -vf "scale=${width}:-1:flags=lanczos,palettegen=stats_mode=diff" \
    "$palette" >/dev/null 2>&1

  ffmpeg -y -framerate "$fps" -i "$src/%03d.png" -i "$palette" \
    -lavfi "scale=${width}:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
    "$out" >/dev/null 2>&1
elif command -v magick >/dev/null 2>&1; then
  delay=$(( 100 / fps ))
  magick -delay "$delay" -loop 0 "$src"/*.png -layers Optimize -resize "${width}x" "$out"
else
  echo "Need ffmpeg or magick on PATH" >&2; exit 1
fi

bytes=$(wc -c < "$out" | tr -d ' ')
echo "GIF written: $out (${bytes} bytes)"
