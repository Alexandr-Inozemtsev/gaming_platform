import { readFile } from 'node:fs/promises';

import { canonicalManifestPath, mirrorManifestPath } from './mobile-runtime-manifest-paths.mjs';

function normalizeManifest(raw) {
  return JSON.stringify(JSON.parse(raw), null, 2);
}

const [canonicalRaw, mirrorRaw] = await Promise.all([
  readFile(canonicalManifestPath, 'utf8'),
  readFile(mirrorManifestPath, 'utf8'),
]);

const canonical = normalizeManifest(canonicalRaw);
const mirror = normalizeManifest(mirrorRaw);

if (canonical !== mirror) {
  console.error('Mobile runtime manifest desync detected.');
  console.error(`Canonical: ${canonicalManifestPath}`);
  console.error(`Mirror: ${mirrorManifestPath}`);
  console.error('Run: npm run sync:mobile-runtime-manifest');
  process.exit(1);
}

console.log('Mobile runtime manifests are in sync.');
