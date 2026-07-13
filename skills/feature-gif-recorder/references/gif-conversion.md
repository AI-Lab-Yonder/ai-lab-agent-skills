# GIF Conversion

Use the tested cross-platform Node helper rather than shell-specific path or glob handling.

## Command

Resolve the installed skill directory, then run:

```text
node <skill-dir>/scripts/frames-to-gif.mjs <run-dir> [fps] [width]
```

Defaults:

| Setting | Default | Valid range |
|---|---:|---:|
| FPS | 4 | greater than 0 and at most 60 |
| Width | 720 | integer from 1 through 16384 |

The helper:

- Accepts the exact run directory, including timestamped directories and paths with spaces
- Reads only contiguous `000.png`, `001.png`, ... frames
- Ignores helper images such as `_palette.png`
- Prefers ffmpeg with two-pass palette generation
- Falls back to ImageMagick when `magick` is available
- Fails clearly when no converter is installed or no valid frames exist

## ffmpeg Strategy

The helper uses lanczos scaling, palette generation with `stats_mode=diff`, and palette application with bounded Bayer dithering and `diff_mode=rectangle`. This reduces shimmer in mostly static interfaces.

## ImageMagick Fallback

The helper passes each validated frame path to `magick`, avoiding shell glob differences. ImageMagick generally produces a larger or less stable palette than the ffmpeg path, so the summary must report which engine was used.

## Size Guidance

- Inline review or changelog asset: target 2 MB or less
- Documentation asset: target 5 MB or less
- Above 8 MB: consider fewer frames, lower FPS, a smaller width, or a video format supported by the intended host

Do not assume every pull-request renderer accepts embedded video.

## Repository Size

Frames, scripts, and metadata should normally remain uncommitted. If the user explicitly chooses to commit GIFs, discuss repository growth first. Suggest Git LFS or an external approved artifact store only when appropriate; never change `.gitattributes` automatically.
