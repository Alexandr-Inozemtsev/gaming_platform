// Назначение файла: задать единые дизайн-токены Flutter-клиента MVP (цвета, типографика, радиусы и отступы).
// Роль в проекте: быть единственным источником UI-констант, чтобы экраны выглядели согласованно и упрощали дальнейший редизайн.
// Основные функции: хранить палитру, размеры шрифтов, радиусы компонентов, интервалы и базовые ThemeData-настройки.
// Связи с другими файлами: используется в main.dart и всех виджетах экранов через AppTheme/AppTokens.
// Важно при изменении: сохранять обратную совместимость имён токенов и не дублировать значения в отдельных экранах.

import 'package:flutter/material.dart';

class AppTokens {
  static const Color bg = Color(0xFF0B1020);
  static const Color card = Color(0xFF141B2D);
  static const Color text = Color(0xFFE6EAF2);
  static const Color muted = Color(0xFF9AA4B2);
  static const Color accent = Color(0xFF6EE7FF);
  static const Color danger = Color(0xFFFF5C7A);
  static const Color ok = Color(0xFF4EE59A);
  static const Color boardGridLine = Color(0xFF22304D);
  static const Color boardHighlight = Color(0xFF6EE7FF);
  static const Color priceTag = Color(0xFFFFD166);
  static const Color storeBadgeNew = Color(0xFF6EE7FF);
  static const Color editorWarning = Color(0xFFFFB020);
  static const Color videoOverlayBg = Color(0x59000000);

  static const String fontFamily = 'Inter';

  static const double h1 = 22;
  static const double h2 = 18;
  static const double editorSectionTitle = 18;
  static const double videoTileRadius = 12;
  static const double body = 14;
  static const double caption = 12;

  static const double radiusCard = 16;
  static const double radiusButton = 14;

  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
}

class AppTheme {
  static ThemeData build() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppTokens.fontFamily,
      scaffoldBackgroundColor: AppTokens.bg,
      cardColor: AppTokens.card,
      colorScheme: const ColorScheme.dark(
        primary: AppTokens.accent,
        secondary: AppTokens.ok,
        error: AppTokens.danger,
        surface: AppTokens.card,
        onSurface: AppTokens.text
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: AppTokens.h1, color: AppTokens.text, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontSize: AppTokens.h2, color: AppTokens.text, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: AppTokens.body, color: AppTokens.text),
        bodySmall: TextStyle(fontSize: AppTokens.caption, color: AppTokens.muted)
      ),
      cardTheme: CardThemeData(
        color: AppTokens.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusCard))
      )
    );
  }
}
