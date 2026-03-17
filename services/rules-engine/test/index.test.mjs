import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const src = readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');
assert.equal(src.includes('tile_placement_demo'), true);
assert.equal(src.includes('roll_and_write_demo'), true);
