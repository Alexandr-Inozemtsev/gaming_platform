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
    'gameplay.bg': 'assets/design/placeholders/gameplay.board.surface.grid.svg',
    'gameplay.decor': 'assets/design/placeholders/gameplay.board.surface.grid.svg',
  };

  static const String _defaultFallbackAsset = 'assets/design/placeholders/onboarding.hero.tabletop.svg';

  Map<String, dynamic>? _manifest;

  Future<void> warmup() async {
    _manifest ??= jsonDecode(await rootBundle.loadString('assets/design/asset-manifest.json')) as Map<String, dynamic>;
  }

  Future<String?> firstInCategory(String category) async {
    await warmup();
    final categories = _manifest?['categories'] as Map<String, dynamic>?;
    final list = categories?[category] as List<dynamic>?;
    if (list == null || list.isEmpty) return null;
    return list.first.toString();
  }

  Future<String?> resolveAsset(String key, {String variant = 'webp@2x'}) async {
    await warmup();
    final assets = _manifest?['assets'] as Map<String, dynamic>?;
    final entry = assets?[key] as Map<String, dynamic>?;
    if (entry == null) return null;

    final resolved = entry[variant] ?? entry['runtime@procedural'] ?? entry['svg'] ?? entry['webp@2x'];
    return resolved?.toString();
  }

  // Controlled fallback: placeholders разрешены только как запасной вариант, а не базовая стратегия.
  Future<String> resolveAssetOrFallback(String key, {String variant = 'webp@2x'}) async {
    final resolvedAsset = await resolveAsset(key, variant: variant);
    if (resolvedAsset != null) return resolvedAsset;

    final fallback = _controlledFallbacks.entries
            .firstWhere((entry) => key.contains(entry.key), orElse: () => const MapEntry('', _defaultFallbackAsset))
            .value;

    assert(() {
      debugPrint('[RuntimeAssetPack] Fallback asset used for key="$key": $fallback');
      return true;
    }());

    return fallback;
  }

  @Deprecated('Use resolveAssetOrFallback to keep placeholders as controlled fallback only.')
  Future<String> resolvePlaceholder(String key) => resolveAssetOrFallback(key);
}
