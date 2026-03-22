// Назначение файла: runtime-загрузка asset manifest и выдача путей ассетов для экранов.
// Роль в проекте: дать единый слой резолва visual assets вместо хардкода путей в виджетах.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RuntimeAssetPack {
  RuntimeAssetPack._();

  static final RuntimeAssetPack instance = RuntimeAssetPack._();

  static const Map<String, String> _controlledFallbacks = {
    'onboarding.hero.tabletop': 'assets/design/placeholders/onboarding.hero.tabletop.svg',
    'gameplay.board.surface.grid': 'assets/design/placeholders/gameplay.board.surface.grid.svg',
    'gameplay.bg.procedural_room': 'assets/design/placeholders/gameplay.board.surface.grid.svg',
    'gameplay.board.surface.travel_grid': 'assets/design/placeholders/gameplay.board.surface.grid.svg',
  };

  static const String _defaultFallbackAsset = 'assets/design/placeholders/onboarding.hero.tabletop.svg';
  static const String _assetBaseUrl = String.fromEnvironment('ASSET_BASE_URL', defaultValue: '');
  static const String _assetManifestSchemaSummary =
      'assets: { <key>: { raster@2x: String|{remote,fallback}, webp@2x?: String, svg?: String, runtime@procedural?: String } }';

  Map<String, dynamic>? _manifest;

  Future<void> warmup() async {
    _manifest ??= jsonDecode(await rootBundle.loadString('assets/design/asset-manifest.json')) as Map<String, dynamic>;
    _assertManifestContract();
  }

  Future<String?> firstInCategory(String category) async {
    await warmup();
    final categories = _manifest?['categories'] as Map<String, dynamic>?;
    final list = categories?[category] as List<dynamic>?;
    if (list == null || list.isEmpty) return null;
    return list.first.toString();
  }

  Future<String?> resolveAsset(String key, {String variant = 'raster@2x'}) async {
    await warmup();
    final assets = _manifest?['assets'] as Map<String, dynamic>?;
    final entry = assets?[key] as Map<String, dynamic>?;
    if (entry == null) return null;

    final dynamic selectedVariantEntry =
        entry[variant] ??
        entry['raster@2x'] ??
        entry['runtime@procedural'] ??
        entry['svg'] ??
        entry['webp@2x'];

    return _resolveVariantEntry(
      key: key,
      requestedVariant: variant,
      selectedVariantEntry: selectedVariantEntry,
    );
  }

  // Controlled fallback: placeholders разрешены только как запасной вариант, а не базовая стратегия.
  Future<String> resolveAssetOrFallback(String key, {String variant = 'raster@2x'}) async {
    final resolvedAsset = await resolveAsset(key, variant: variant);
    if (resolvedAsset != null) {
      assert(() {
        debugPrint('[RuntimeAssetPack] key="$key" variant="$variant" strategy="remote_or_manifest".');
        return true;
      }());
      return resolvedAsset;
    }

    final fallback = _controlledFallbacks[key] ?? _defaultFallbackAsset;

    assert(() {
      debugPrint('[RuntimeAssetPack] key="$key" variant="$variant" strategy="fallback" asset="$fallback".');
      return true;
    }());

    return fallback;
  }

  /// Expected manifest contract for runtime asset resolution:
  /// - root object has `assets` map;
  /// - each asset entry is a map of variant -> value;
  /// - supported values:
  ///   * `String` for local asset or runtime marker;
  ///   * `{ remote: String, fallback: String }` map for CDN-enabled variants.
  /// - Big Walker requires:
  ///   * gameplay.board.surface.travel_grid.raster@2x
  ///   * gameplay.bg.procedural_room.runtime@procedural
  void _assertManifestContract() {
    final dynamic assets = _manifest?['assets'];
    if (assets is! Map<String, dynamic>) {
      assert(() {
        debugPrint('[RuntimeAssetPack] Invalid manifest schema: missing assets map. Expected $_assetManifestSchemaSummary');
        return true;
      }());
      return;
    }

    _assertEntryHasVariant(assets, 'gameplay.board.surface.travel_grid', 'raster@2x');
    _assertEntryHasVariant(assets, 'gameplay.bg.procedural_room', 'runtime@procedural');
  }

  void _assertEntryHasVariant(Map<String, dynamic> assets, String key, String variant) {
    final entry = assets[key];
    final hasVariant = entry is Map<String, dynamic> && entry[variant] != null;
    if (hasVariant) return;
    assert(() {
      debugPrint(
        '[RuntimeAssetPack] Invalid manifest schema: missing "$variant" for "$key". '
        'Expected $_assetManifestSchemaSummary',
      );
      return true;
    }());
  }

  String? _resolveVariantEntry({
    required String key,
    required String requestedVariant,
    required dynamic selectedVariantEntry,
  }) {
    if (selectedVariantEntry is String) return selectedVariantEntry;
    if (selectedVariantEntry is! Map<String, dynamic>) return null;

    final remote = selectedVariantEntry['remote']?.toString();
    final localFallback = selectedVariantEntry['fallback']?.toString();
    if ((remote == null || remote.isEmpty) && (localFallback == null || localFallback.isEmpty)) {
      assert(() {
        debugPrint(
          '[RuntimeAssetPack] Invalid variant entry for "$key" variant="$requestedVariant": '
          'map must contain non-empty remote or fallback.',
        );
        return true;
      }());
      return null;
    }
    final resolvedRemote = _withAssetBaseUrl(remote);
    final resolved = (resolvedRemote?.isNotEmpty ?? false) ? resolvedRemote : localFallback;
    final strategy = (resolvedRemote?.isNotEmpty ?? false) ? 'remote' : 'local_manifest_fallback';

    assert(() {
      debugPrint(
        '[RuntimeAssetPack] key="$key" variant="$requestedVariant" strategy="$strategy" resolved="${resolved ?? 'null'}".',
      );
      return true;
    }());

    return resolved;
  }

  String? _withAssetBaseUrl(String? remotePathOrUrl) {
    if (remotePathOrUrl == null || remotePathOrUrl.isEmpty) return null;
    if (remotePathOrUrl.startsWith('http://') || remotePathOrUrl.startsWith('https://')) return remotePathOrUrl;
    if (_assetBaseUrl.isEmpty) return null;
    final base = _assetBaseUrl.endsWith('/') ? _assetBaseUrl.substring(0, _assetBaseUrl.length - 1) : _assetBaseUrl;
    final path = remotePathOrUrl.startsWith('/') ? remotePathOrUrl : '/$remotePathOrUrl';
    return '$base$path';
  }

  @Deprecated('Use resolveAssetOrFallback to keep placeholders as controlled fallback only.')
  Future<String> resolvePlaceholder(String key) => resolveAssetOrFallback(key);
}
