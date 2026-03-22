import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

import { canonicalManifestPath, mirrorManifestPath } from './mobile-runtime-manifest-paths.mjs';

const canonicalRaw = await readFile(canonicalManifestPath, 'utf8');
const manifest = JSON.parse(canonicalRaw);
const normalized = `${JSON.stringify(manifest, null, 2)}\n`;

await mkdir(path.dirname(mirrorManifestPath), { recursive: true });
await writeFile(mirrorManifestPath, normalized, 'utf8');

console.log(`Synced mobile runtime manifest:\n- source: ${canonicalManifestPath}\n- target: ${mirrorManifestPath}`);
