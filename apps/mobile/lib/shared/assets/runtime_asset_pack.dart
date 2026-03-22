// Назначение файла: runtime-загрузка asset manifest и выдача путей ассетов для экранов.
// Роль в проекте: дать единый слой резолва visual assets вместо хардкода путей в виджетах.

import 'dart:convert';

import 'package:flutter/services.dart';

class RuntimeAssetPack {
  RuntimeAssetPack._();

  static final RuntimeAssetPack instance = RuntimeAssetPack._();

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
    final resolved = entry?[variant];
    return resolved?.toString();
  }

  // Упрощённый резолвер ключа в файл-заглушку для MVP до подключения CDN/генератора.
  Future<String> resolvePlaceholder(String key) async {
    final resolvedAsset = await resolveAsset(key);
    if (resolvedAsset != null) return resolvedAsset;
    if (key.contains('onboarding.hero.tabletop')) return 'assets/design/placeholders/onboarding.hero.tabletop.svg';
    if (key.contains('gameplay.board.surface.grid')) return 'assets/design/placeholders/gameplay.board.surface.grid.svg';
    return 'assets/design/placeholders/onboarding.hero.tabletop.svg';
  }
}
