// Назначение файла: централизовать production-ready дизайн-токены и правила адаптации для landscape-first MVP.
// Роль в проекте: единый источник цветов, типографики, отступов, радиусов, глубины, motion и layout-констант.
// Основные функции: предоставить token-слой для reusable UI-kit и экранов iOS/Android без дублирования чисел.
// Связи с другими файлами: используется main.dart, shared/ui/*, feature-контейнерами и документацией дизайн-системы.
// Важно при изменении: вносить изменения только через токены, чтобы сохранить предсказуемость мультиплатформенной адаптации.

import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryFig = Color(0xFF6EE7FF);
  static const Color campaignHeader = Color(0xFF6EE7FF);
  static const Color campaignBg = Color(0xFF141B2D);
  static const Color deploySuccess = Color(0xFF4EE59A);
  static const Color deployWarn = Color(0xFFFFB020);
  static const Color gameModeBadge = Color(0xFFFFD166);
  static const Color storePriceAccent = Color(0xFFFFB020);
  static const Color storeAlertBg = Color(0xFF222831);
  static const Color videoActive = Color(0xFF4EE59A);
  static const Color videoBorder = Color(0xFFFFFFFF);
  static const Color bgBase = Color(0xFF0F1115);
  static const Color bgElevated1 = Color(0xFF171A21);
  static const Color bgElevated2 = Color(0xFF1E2430);
  static const Color bgPanel = Color(0xFF232A38);

  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFB9C1CC);
  static const Color textMuted = Color(0xFF7E8794);
  static const Color textInverse = Color(0xFF0F1115);

  static const Color accentPrimary = Color(0xFF2EC5B6);
  static const Color accentPrimaryHover = Color(0xFF37D6C6);
  static const Color accentPrimaryPressed = Color(0xFF21A89B);
  static const Color accentPrimarySoft = Color(0xFF183C3A);

  static const Color accentSecondary = Color(0xFFF2B24D);
  static const Color accentSecondaryHover = Color(0xFFFFC76A);
  static const Color accentSecondaryPressed = Color(0xFFD89A36);
  static const Color accentSecondarySoft = Color(0xFF4A3720);

  static const Color success = Color(0xFF49C97D);
  static const Color warning = Color(0xFFF2B24D);
  static const Color error = Color(0xFFE56767);
  static const Color info = Color(0xFF5EA8FF);

  static const Color strokeSoft = Color(0xFF2D3442);
  static const Color strokeDefault = Color(0xFF394254);
  static const Color strokeStrong = Color(0xFF4A556B);

  static const Color turnActive = Color(0xFF2EC5B6);
  static const Color turnOpponent = Color(0xFF5EA8FF);
  static const Color dangerZone = Color(0xFFE56767);
  static const Color rewardGlow = Color(0xFFF2B24D);
}

class AppTypography {
  static const String headingFamily = 'Manrope';
  static const String bodyFamily = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: headingFamily,
    fontSize: 32,
    height: 1.1,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary
  );
  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary
  );
  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary
  );
  static const TextStyle label = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary
  );
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted
  );
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;
}

class AppOpacity {
  static const double disabled = 0.5;
  static const double overlay = 0.65;
  static const double subtle = 0.2;
}

class AppElevation {
  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 3)),
  ];
  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x44000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> glowPrimary = [
    BoxShadow(color: Color(0x6637D6C6), blurRadius: 20, spreadRadius: 1),
  ];
  static const List<BoxShadow> glowSecondary = [
    BoxShadow(color: Color(0x66FFC76A), blurRadius: 20, spreadRadius: 1),
  ];
}

class AppZ {
  static const int base = 0;
  static const int hud = 10;
  static const int sheet = 20;
  static const int overlay = 30;
  static const int modal = 40;
  static const int toast = 50;
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 320);

  static const Curve easeStandard = Curves.easeOutCubic;
  static const Curve easeEmphasized = Curves.easeInOutCubicEmphasized;
  static const Curve easeExit = Curves.easeInCubic;
}

enum LandscapeSizeClass { compact, regular, large }

class AppLayout {
  static const double minTouchTarget = 44;
  static const double maxContentWidth = 1180;
  static const double sidePanelWidthCompact = 280;
  static const double sidePanelWidthRegular = 320;
  static const double sidePanelWidthLarge = 360;

  static LandscapeSizeClass sizeClass(double width) {
    if (width < 900) return LandscapeSizeClass.compact;
    if (width < 1180) return LandscapeSizeClass.regular;
    return LandscapeSizeClass.large;
  }

  // Для landscape-first считаем приоритетно доступную высоту и ширину после safe area.
  static bool useCollapsedPanels(Size size) => size.width < 900 || size.height < 430;

  static EdgeInsets safeAwarePadding(BuildContext context, {double horizontal = AppSpacing.md, double vertical = AppSpacing.sm}) {
    final insets = MediaQuery.paddingOf(context);
    return EdgeInsets.fromLTRB(
      horizontal + insets.left,
      vertical + insets.top,
      horizontal + insets.right,
      vertical + insets.bottom
    );
  }
}

class AppTheme {
  static ThemeData build() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppTypography.bodyFamily,
      scaffoldBackgroundColor: AppColors.bgBase,
      cardColor: AppColors.bgElevated1,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPrimary,
        secondary: AppColors.accentSecondary,
        error: AppColors.error,
        surface: AppColors.bgPanel,
        onSurface: AppColors.textPrimary
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTypography.h1,
        headlineSmall: AppTypography.h2,
        titleMedium: AppTypography.h3,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelMedium: AppTypography.label
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgElevated1,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.strokeSoft),
          borderRadius: BorderRadius.circular(AppRadius.md)
        )
      )
    );
  }
}

// Совместимость с существующими экранами, пока идёт поэтапная миграция на AppColors/AppSpacing.
// Game-specific токены (например Big Walker) выносим в `theme/game/*_tokens.dart` — см. `theme/game/big_walker_tokens.dart`.
class AppTokens {
  static const Color bg = AppColors.bgBase;
  static const Color card = AppColors.bgElevated1;
  static const Color text = AppColors.textPrimary;
  static const Color muted = AppColors.textMuted;
  static const Color accent = AppColors.accentPrimary;
  static const Color danger = AppColors.error;
  static const Color ok = AppColors.success;
  static const Color boardGridLine = AppColors.strokeSoft;
  static const Color boardHighlight = AppColors.turnActive;
  static const Color priceTag = AppColors.accentSecondary;
  static const Color storeBadgeNew = AppColors.accentPrimary;
  static const Color editorWarning = AppColors.warning;
  static const Color videoOverlayBg = Color(0x99000000);
  static const Color analyticsChartLine = AppColors.info;
  static const Color analyticsAxis = AppColors.textMuted;
  static const Color qaPass = AppColors.success;
  static const Color qaFail = AppColors.error;
  static const Color releaseOk = AppColors.success;
  static const Color releaseFail = AppColors.error;
  static const Color modCaseOpen = AppColors.warning;
  static const Color modCaseClosed = AppColors.success;

  static const String fontFamily = AppTypography.bodyFamily;

  static const double h1 = 24;
  static const double uiButtonRadius = 20;
  static const double uiPadding = 16;
  static const double textItalic = 12;
  static const double h2 = 20;
  static const double editorSectionTitle = 18;
  static const double videoTileRadius = AppRadius.sm;
  static const double body = 15;
  static const double caption = 11;

  static const double radiusCard = AppRadius.md;
  static const double radiusButton = AppRadius.sm;

  static const double s8 = AppSpacing.xs;
  static const double s12 = AppSpacing.sm;
  static const double s16 = AppSpacing.md;
  static const double s24 = AppSpacing.xl;
}
