import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdir, mkdtemp, rm, stat, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { basename, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

import { collectFrames, convertFrames } from './frames-to-gif.mjs';

function commandAvailable(command) {
  const result = spawnSync(command, ['-version'], { stdio: 'ignore' });
  return !result.error && result.status === 0;
}

async function createRunDir(name = 'feature run') {
  const root = await mkdtemp(join(tmpdir(), 'frames-to-gif-'));
  const runDir = join(root, name);
  const framesDir = join(runDir, 'frames');
  await mkdir(framesDir, { recursive: true });
  await writeFile(join(framesDir, '000.png'), 'frame zero');
  await writeFile(join(framesDir, '001.png'), 'frame one');
  await writeFile(join(framesDir, '_palette.png'), 'ignored helper file');
  return { framesDir, root, runDir };
}

test('collectFrames returns only contiguous numbered frames', async (t) => {
  const fixture = await createRunDir();
  t.after(() => rm(fixture.root, { force: true, recursive: true }));

  assert.deepEqual(await collectFrames(fixture.framesDir), ['000.png', '001.png']);
});

test('collectFrames rejects gaps in the numbered sequence', async (t) => {
  const fixture = await createRunDir();
  t.after(() => rm(fixture.root, { force: true, recursive: true }));
  await rm(join(fixture.framesDir, '001.png'));
  await writeFile(join(fixture.framesDir, '002.png'), 'frame two');

  await assert.rejects(
    collectFrames(fixture.framesDir),
    /expected 001\.png, found 002\.png/,
  );
});

test('ffmpeg conversion preserves paths with spaces and uses two passes', async (t) => {
  const fixture = await createRunDir('feature with spaces');
  t.after(() => rm(fixture.root, { force: true, recursive: true }));
  const calls = [];

  const result = await convertFrames(fixture.runDir, {
    fps: 5,
    width: 640,
    probe: (command) => command === 'ffmpeg',
    runner: async (command, args) => {
      calls.push({ command, args });
      await writeFile(args.at(-1), calls.length === 1 ? 'palette' : 'gif-output');
    },
  });

  assert.equal(result.engine, 'ffmpeg');
  assert.equal(result.frameCount, 2);
  assert.equal(result.outputPath, join(fixture.runDir, `${basename(fixture.runDir)}.gif`));
  assert.equal(calls.length, 2);
  assert.equal(calls[0].command, 'ffmpeg');
  assert.ok(calls[0].args.includes(join(fixture.framesDir, '%03d.png')));
  assert.ok(calls[0].args.includes('scale=640:-1:flags=lanczos,palettegen=stats_mode=diff'));
  assert.equal(calls[1].args.at(-1), result.outputPath);
  assert.ok(result.bytes > 0);
  await assert.rejects(stat(join(fixture.framesDir, '_palette.png')));
});

test('ImageMagick fallback passes validated frame paths explicitly', async (t) => {
  const fixture = await createRunDir();
  t.after(() => rm(fixture.root, { force: true, recursive: true }));
  const calls = [];

  const result = await convertFrames(fixture.runDir, {
    fps: 4,
    width: 720,
    probe: (command) => command === 'magick',
    runner: async (command, args) => {
      calls.push({ command, args });
      await writeFile(args.at(-1), 'gif-output');
    },
  });

  assert.equal(result.engine, 'magick');
  assert.equal(calls.length, 1);
  assert.equal(calls[0].command, 'magick');
  assert.ok(calls[0].args.includes(join(fixture.framesDir, '000.png')));
  assert.ok(calls[0].args.includes(join(fixture.framesDir, '001.png')));
  assert.ok(!calls[0].args.includes(join(fixture.framesDir, '_palette.png')));
  assert.equal(calls[0].args.at(-1), result.outputPath);
});

test('conversion rejects invalid arguments before running a converter', async (t) => {
  const fixture = await createRunDir();
  t.after(() => rm(fixture.root, { force: true, recursive: true }));
  const neverRun = () => {
    throw new Error('converter should not run');
  };

  await assert.rejects(
    convertFrames(fixture.runDir, { fps: 0, probe: neverRun, runner: neverRun }),
    /fps must be/,
  );
  await assert.rejects(
    convertFrames(fixture.runDir, { width: 12.5, probe: neverRun, runner: neverRun }),
    /width must be/,
  );
});

test('conversion fails clearly when no supported converter is available', async (t) => {
  const fixture = await createRunDir();
  t.after(() => rm(fixture.root, { force: true, recursive: true }));

  await assert.rejects(
    convertFrames(fixture.runDir, { probe: () => false }),
    /neither ffmpeg nor ImageMagick magick is available/,
  );
});

test('CLI entry point reports usage when the run directory is missing', () => {
  const scriptPath = fileURLToPath(new URL('./frames-to-gif.mjs', import.meta.url));
  const result = spawnSync(process.execPath, [scriptPath], { encoding: 'utf8' });

  assert.equal(result.status, 1);
  assert.match(result.stderr, /usage: frames-to-gif\.mjs/);
});

test('real ffmpeg conversion creates a non-empty GIF', {
  skip: !(commandAvailable('ffmpeg') && commandAvailable('magick')),
}, async (t) => {
  const fixture = await createRunDir('real conversion');
  t.after(() => rm(fixture.root, { force: true, recursive: true }));

  for (const [name, color] of [['000.png', 'red'], ['001.png', 'blue']]) {
    const generated = spawnSync('magick', [
      '-size', '16x16',
      `xc:${color}`,
      join(fixture.framesDir, name),
    ], { encoding: 'utf8' });
    assert.equal(generated.status, 0, generated.stderr);
  }

  const result = await convertFrames(fixture.runDir, { fps: 2, width: 32 });
  assert.equal(result.engine, 'ffmpeg');
  assert.equal(result.frameCount, 2);
  assert.ok(result.bytes > 0);
  assert.ok((await stat(result.outputPath)).isFile());
});

test('real ImageMagick fallback creates a non-empty GIF', {
  skip: !commandAvailable('magick'),
}, async (t) => {
  const fixture = await createRunDir('real magick conversion');
  t.after(() => rm(fixture.root, { force: true, recursive: true }));

  for (const [name, color] of [['000.png', 'green'], ['001.png', 'yellow']]) {
    const generated = spawnSync('magick', [
      '-size', '16x16',
      `xc:${color}`,
      join(fixture.framesDir, name),
    ], { encoding: 'utf8' });
    assert.equal(generated.status, 0, generated.stderr);
  }

  const result = await convertFrames(fixture.runDir, {
    fps: 2,
    width: 32,
    probe: (command) => command === 'magick',
  });
  assert.equal(result.engine, 'magick');
  assert.equal(result.frameCount, 2);
  assert.ok(result.bytes > 0);
  assert.ok((await stat(result.outputPath)).isFile());
});
