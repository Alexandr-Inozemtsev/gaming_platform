import { readFile } from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';

const repoRoot = process.cwd();

const manifestPath = path.join(repoRoot, 'apps/mobile/assets/design/asset-manifest.json');
const tokensPath = path.join(repoRoot, 'apps/mobile/lib/theme/game/big_walker_tokens.dart');
const resolverPath = path.join(repoRoot, 'apps/mobile/lib/shared/assets/runtime_asset_pack.dart');

function extractConst(source, constName) {
  const escaped = constName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const pattern = new RegExp(`static const String ${escaped}\\s*=\\s*'([^']+)';`, 'm');
  const match = source.match(pattern);
  return match?.[1] ?? null;
}

function assertCondition(errors, condition, message) {
  if (!condition) errors.push(message);
}

const [manifestRaw, tokensRaw, resolverRaw] = await Promise.all([
  readFile(manifestPath, 'utf8'),
  readFile(tokensPath, 'utf8'),
  readFile(resolverPath, 'utf8'),
]);

const manifest = JSON.parse(manifestRaw);
const errors = [];

const tokenDefaultVariant = extractConst(tokensRaw, 'defaultRasterVariant');
const tokenLegacyVariant = extractConst(tokensRaw, 'legacyWebpVariant');
const travelGridKey = extractConst(tokensRaw, 'gameplayBoardSurfaceTravelGridKey');
const proceduralRoomKey = extractConst(tokensRaw, 'gameplayBackgroundProceduralRoomKey');
const travelGridPath = extractConst(tokensRaw, 'gameplayBoardSurfaceTravelGridAssetPath');

assertCondition(errors, tokenDefaultVariant === 'raster@2x', 'BigWalkerTokens.defaultRasterVariant должен быть raster@2x.');
assertCondition(errors, tokenLegacyVariant === 'webp@2x', 'BigWalkerTokens.legacyWebpVariant должен быть webp@2x.');
assertCondition(errors, Boolean(travelGridKey), 'BigWalkerTokens.gameplayBoardSurfaceTravelGridKey не найден.');
assertCondition(errors, Boolean(proceduralRoomKey), 'BigWalkerTokens.gameplayBackgroundProceduralRoomKey не найден.');
assertCondition(errors, Boolean(travelGridPath), 'BigWalkerTokens.gameplayBoardSurfaceTravelGridAssetPath не найден.');

const variantPolicy = manifest.variant_policy ?? {};
assertCondition(errors, Boolean(variantPolicy['raster@2x']), 'asset-manifest.variant_policy.raster@2x отсутствует.');
assertCondition(errors, Boolean(variantPolicy['raster@3x']), 'asset-manifest.variant_policy.raster@3x отсутствует.');

const exportsTexture = manifest.exports?.texture ?? [];
assertCondition(
  errors,
  Array.isArray(exportsTexture) && exportsTexture.includes('raster@2x'),
  'asset-manifest.exports.texture должен включать raster@2x.',
);

const assets = manifest.assets ?? {};
assertCondition(errors, manifest.assets && typeof manifest.assets === 'object', 'asset-manifest.assets секция отсутствует.');
const travelGridEntry = assets[travelGridKey];
assertCondition(errors, Boolean(travelGridEntry), `asset-manifest.assets[${travelGridKey}] отсутствует.`);
if (travelGridEntry) {
  const defaultVariantEntry = travelGridEntry[tokenDefaultVariant];
  assertCondition(
    errors,
    typeof defaultVariantEntry === 'object' && defaultVariantEntry !== null,
    `asset-manifest.assets[${travelGridKey}].${tokenDefaultVariant} должен быть объектом c remote/fallback.`,
  );
  assertCondition(
    errors,
    defaultVariantEntry?.fallback === travelGridPath,
    `asset-manifest.assets[${travelGridKey}].${tokenDefaultVariant}.fallback должен совпадать с token path.`,
  );
  assertCondition(
    errors,
    typeof defaultVariantEntry?.remote === 'string' && defaultVariantEntry.remote.length > 0,
    `asset-manifest.assets[${travelGridKey}].${tokenDefaultVariant}.remote должен быть задан.`,
  );
  assertCondition(
    errors,
    typeof travelGridEntry[tokenLegacyVariant] === 'string',
    `asset-manifest.assets[${travelGridKey}].${tokenLegacyVariant} должен быть задан для legacy-совместимости.`,
  );
  assertCondition(
    errors,
    typeof travelGridEntry.svg === 'string' && travelGridEntry.svg.length > 0,
    `asset-manifest.assets[${travelGridKey}].svg должен быть задан для fallback preview/дизайн-пайплайна.`,
  );
}

const proceduralRoomEntry = assets[proceduralRoomKey];
assertCondition(errors, Boolean(proceduralRoomEntry), `asset-manifest.assets[${proceduralRoomKey}] отсутствует.`);
if (proceduralRoomEntry) {
  assertCondition(
    errors,
    typeof proceduralRoomEntry['runtime@procedural'] === 'string',
    `asset-manifest.assets[${proceduralRoomKey}].runtime@procedural должен быть строкой.`,
  );
  assertCondition(
    errors,
    typeof proceduralRoomEntry.svg === 'string' && proceduralRoomEntry.svg.length > 0,
    `asset-manifest.assets[${proceduralRoomKey}].svg должен быть задан для дизайн-документации и CI snapshot-проверок.`,
  );
}

const resolveAssetDefaultMatch = resolverRaw.match(/resolveAsset\(String key, \{String variant = '([^']+)'\}\)/);
assertCondition(
  errors,
  resolveAssetDefaultMatch?.[1] === tokenDefaultVariant,
  'RuntimeAssetPack.resolveAsset default variant не совпадает с BigWalkerTokens.defaultRasterVariant.',
);

const resolveFallbackDefaultMatch = resolverRaw.match(/resolveAssetOrFallback\(String key, \{String variant = '([^']+)'\}\)/);
assertCondition(
  errors,
  resolveFallbackDefaultMatch?.[1] === tokenDefaultVariant,
  'RuntimeAssetPack.resolveAssetOrFallback default variant не совпадает с BigWalkerTokens.defaultRasterVariant.',
);

const resolverOrderSnippet = "entry[variant] ??\n        entry['raster@2x'] ??\n        entry['runtime@procedural'] ??\n        entry['svg'] ??\n        entry['webp@2x']";
assertCondition(
  errors,
  resolverRaw.includes(resolverOrderSnippet),
  'RuntimeAssetPack.resolveAsset должен сохранять порядок policy: requested -> raster@2x -> runtime@procedural -> svg -> webp@2x.',
);

assertCondition(
  errors,
  resolverRaw.includes("final strategy = (resolvedRemote?.isNotEmpty ?? false) ? 'remote' : 'local_manifest_fallback';") &&
    resolverRaw.includes('strategy="$strategy"'),
  'RuntimeAssetPack должен логировать диагностику remote/local_manifest_fallback при resolve variant.',
);

assertCondition(
  errors,
  resolverRaw.includes("strategy=\"fallback\""),
  'RuntimeAssetPack должен логировать controlled fallback для ключей вне manifest.',
);

if (errors.length > 0) {
  console.error('Asset policy validation failed:');
  for (const [index, error] of errors.entries()) {
    console.error(`${index + 1}. ${error}`);
  }
  process.exit(1);
}

console.log('Asset policy validation passed. tokens ↔ manifest ↔ resolver are consistent.');
