#!/usr/bin/env node

import { spawnSync } from 'node:child_process';
import { readdir, stat, unlink } from 'node:fs/promises';
import { basename, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const FRAME_PATTERN = /^\d{3}\.png$/;

function parseFps(value) {
  const fps = Number(value);
  if (!Number.isFinite(fps) || fps <= 0 || fps > 60) {
    throw new Error('fps must be a number greater than 0 and at most 60');
  }
  return fps;
}

function parseWidth(value) {
  const width = Number(value);
  if (!Number.isInteger(width) || width < 1 || width > 16384) {
    throw new Error('width must be an integer from 1 through 16384');
  }
  return width;
}

function defaultProbe(command) {
  const result = spawnSync(command, ['-version'], { stdio: 'ignore' });
  return !result.error && result.status === 0;
}

function defaultRunner(command, args) {
  const result = spawnSync(command, args, { stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${command} exited with status ${result.status}`);
  }
}

export async function collectFrames(framesDir) {
  let entries;
  try {
    entries = await readdir(framesDir, { withFileTypes: true });
  } catch (error) {
    throw new Error(`cannot read frames directory ${framesDir}: ${error.message}`);
  }

  const frames = entries
    .filter((entry) => entry.isFile() && FRAME_PATTERN.test(entry.name))
    .map((entry) => entry.name)
    .sort();

  if (frames.length === 0) {
    throw new Error(`no numbered PNG frames found in ${framesDir}`);
  }

  for (let index = 0; index < frames.length; index += 1) {
    const expected = `${String(index).padStart(3, '0')}.png`;
    if (frames[index] !== expected) {
      throw new Error(`frame sequence must be contiguous from 000.png; expected ${expected}, found ${frames[index]}`);
    }
  }

  return frames;
}

export async function convertFrames(runDir, options = {}) {
  if (!runDir || typeof runDir !== 'string') {
    throw new Error('run directory is required');
  }

  const fps = parseFps(options.fps ?? 4);
  const width = parseWidth(options.width ?? 720);
  const probe = options.probe ?? defaultProbe;
  const runner = options.runner ?? defaultRunner;

  const resolvedRunDir = resolve(runDir);
  const framesDir = join(resolvedRunDir, 'frames');
  const frames = await collectFrames(framesDir);
  const runName = basename(resolvedRunDir);
  if (!runName) {
    throw new Error('run directory must not be a filesystem root');
  }
  const outputPath = join(resolvedRunDir, `${runName}.gif`);
  const palettePath = join(framesDir, '_palette.png');

  let engine;
  if (await probe('ffmpeg')) {
    engine = 'ffmpeg';
    await runner('ffmpeg', [
      '-hide_banner',
      '-loglevel', 'error',
      '-y',
      '-framerate', String(fps),
      '-i', join(framesDir, '%03d.png'),
      '-vf', `scale=${width}:-1:flags=lanczos,palettegen=stats_mode=diff`,
      '-frames:v', '1',
      '-update', '1',
      palettePath,
    ]);
    await runner('ffmpeg', [
      '-hide_banner',
      '-loglevel', 'error',
      '-y',
      '-framerate', String(fps),
      '-i', join(framesDir, '%03d.png'),
      '-i', palettePath,
      '-lavfi', `scale=${width}:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle`,
      '-loop', '0',
      outputPath,
    ]);
  } else if (await probe('magick')) {
    engine = 'magick';
    const delay = Math.max(1, Math.round(100 / fps));
    await runner('magick', [
      '-delay', String(delay),
      '-loop', '0',
      ...frames.map((frame) => join(framesDir, frame)),
      '-layers', 'Optimize',
      '-resize', `${width}x`,
      outputPath,
    ]);
  } else {
    throw new Error('neither ffmpeg nor ImageMagick magick is available on PATH');
  }

  let outputStat;
  try {
    outputStat = await stat(outputPath);
  } catch (error) {
    throw new Error(`converter completed without creating ${outputPath}: ${error.message}`);
  }

  if (!outputStat.isFile() || outputStat.size === 0) {
    throw new Error(`converter produced an empty or invalid output at ${outputPath}`);
  }

  if (engine === 'ffmpeg') {
    await unlink(palettePath).catch(() => {});
  }

  return {
    bytes: outputStat.size,
    engine,
    fps,
    frameCount: frames.length,
    outputPath,
    width,
  };
}

async function main(argv) {
  const [runDir, fps = '4', width = '720'] = argv;
  if (!runDir) {
    throw new Error('usage: frames-to-gif.mjs <run-dir> [fps] [width]');
  }

  const result = await convertFrames(runDir, { fps, width });
  process.stdout.write(`GIF written: ${result.outputPath} (${result.bytes} bytes, ${result.engine})\n`);
}

const invokedPath = process.argv[1] ? pathToFileURL(resolve(process.argv[1])).href : null;
if (invokedPath === import.meta.url) {
  main(process.argv.slice(2)).catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}
