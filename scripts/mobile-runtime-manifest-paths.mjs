import path from 'node:path';
import process from 'node:process';

export const repoRoot = process.cwd();

export const canonicalManifestPath = path.join(repoRoot, 'apps/mobile/assets/design/asset-manifest.json');
export const mirrorManifestPath = path.join(repoRoot, 'assets/design/asset-manifest.json');
