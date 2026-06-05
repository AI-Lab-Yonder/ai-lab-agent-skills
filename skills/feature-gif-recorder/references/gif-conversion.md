# GIF Conversion

How to turn `frames/*.png` into a small, sharp GIF.

## Default: ffmpeg, two-pass with palette

The `scripts/frames-to-gif.sh` helper does this. Manual form:

```bash
slug=add-todo
src="recordings/$slug/frames"
out="recordings/$slug/$slug.gif"
fps=4
width=720

ffmpeg -y -framerate $fps -i "$src/%03d.png" \
  -vf "scale=$width:-1:flags=lanczos,palettegen=stats_mode=diff" \
  "$src/_palette.png"

ffmpeg -y -framerate $fps -i "$src/%03d.png" -i "$src/_palette.png" \
  -lavfi "scale=$width:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
  "$out"
```

`stats_mode=diff` + `paletteuse diff_mode=rectangle` is the magic combo for UI screenshots — it keeps the palette stable between near-identical frames so flat backgrounds don't shimmer.

## Knobs

| Knob              | Effect                                              | Default |
|-------------------|-----------------------------------------------------|---------|
| `fps`             | Frame rate. Higher = smoother + bigger.            | 4       |
| `width`           | Output width in pixels. Height auto-keeps ratio.   | 720     |
| `dither=…`        | `bayer:bayer_scale=5` for UIs, `none` for flat UI. | bayer 5 |
| `loop`            | `-loop 0` infinite, `-loop 1` play once.           | 0       |

## Size targets

- PR / changelog inline: ≤ 2 MB. Drop fps to 3 or width to 600 if you blow past this.
- Docs site hero: ≤ 5 MB.
- If the GIF is > 8 MB, switch to MP4 / WebM. MP4 in a `<video>` tag is 5–10× smaller and loops fine; PRs and most markdown renderers accept it.

```bash
ffmpeg -y -framerate $fps -i "$src/%03d.png" -c:v libx264 -pix_fmt yuv420p \
  -vf "scale=$width:-2:flags=lanczos,fps=$fps" "${out%.gif}.mp4"
```

## ImageMagick fallback

If `ffmpeg` is unavailable but `magick` is:

```bash
magick -delay 25 -loop 0 "$src/*.png" -layers Optimize -resize 720x "$out"
```

Quality is worse — palette per-frame, no diff mode — but acceptable for short flows.

## Repo bloat warning

Recorded GIFs add up fast. If you're committing them, add to `.gitattributes`:

```
recordings/**/*.gif filter=lfs diff=lfs merge=lfs -text
recordings/**/*.png filter=lfs diff=lfs merge=lfs -text
```

Or `.gitignore` the `frames/` folder and only commit the final GIFs.
