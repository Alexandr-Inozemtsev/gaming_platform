import 'package:flutter/material.dart';

class BigWalkerTokens {
  static const int cols = 8;
  static const int rows = 5;
  static const int totalCells = cols * rows;

  static const int minPlayers = 2;
  static const int maxPlayers = 6;
  static const int diceRollFrames = 8;
  static const int diceMin = 1;
  static const int diceMax = 6;

  static const Color bgDeep = Color(0xFF050913);
  static const Color bgMid = Color(0xFF0B1325);
  static const Color bgSoft = Color(0xFF131F36);
  static const Color roomVignette = Color(0xCC02050D);

  static const Color panel = Color(0xCC0D172C);
  static const Color panelSoft = Color(0xCC15243D);
  static const Color panelBorder = Color(0x664C89B8);
  static const Color panelBorderActive = Color(0xAA7AE7FF);

  static const Color accentCyan = Color(0xFF72EDFF);
  static const Color accentCyanSoft = Color(0xFF3CAFD0);
  static const Color accentAmber = Color(0xFFFFC977);
  static const Color accentAmberDeep = Color(0xFFE19033);
  static const Color textPrimary = Color(0xFFF4F8FF);
  static const Color textSecondary = Color(0xFFB5C9E3);
  static const Color textMuted = Color(0xFF87A1BF);

  static const Color boardWoodTop = Color(0xFF2E1E14);
  static const Color boardWoodBottom = Color(0xFF1A110C);
  static const Color boardInnerTop = Color(0xFF15253E);
  static const Color boardInnerBottom = Color(0xFF0D182C);
  static const Color boardBorder = Color(0xCC7DEEFF);
  static const Color boardPathBase = Color(0xFF223F5F);
  static const Color boardPathAlt = Color(0xFF1C3551);
  static const Color boardSpecial = Color(0xFF2D4E76);
  static const Color boardStart = Color(0xFF3ED28B);
  static const Color boardFinish = Color(0xFFF0A44A);

  static const double scenePadding = 12;
  static const double sceneRadius = 24;
  static const double tableRadius = 28;
  static const double tableHeightFactor = 0.76;
  static const double boardRadius = 20;
  static const double panelRadius = 16;
  static const double chipRadius = 999;
  static const double cellRadius = 16;
  static const double cellGap = 4;
  static const double pawnRadius = 11;
  static const double pawnStrokeWidth = 1.5;
  static const double actionButtonHeight = 56;
  static const double iconButtonSize = 36;

  static const double space2 = 2;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space16 = 16;

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 360);

  static const LinearGradient roomGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDeep, bgMid],
  );

  static const LinearGradient tableGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2A1E17), Color(0xFF1A130F), Color(0xFF110D0A)],
  );

  static const LinearGradient panelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [panelSoft, panel],
  );

  static const LinearGradient boardInnerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [boardInnerTop, boardInnerBottom],
  );

  static const LinearGradient rollButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentAmber, accentAmberDeep],
  );

  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: Color(0x3D5DDAFF), blurRadius: 24, spreadRadius: 1),
    BoxShadow(color: Color(0x2FB98A4D), blurRadius: 30, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> boardShadow = [
    BoxShadow(color: Color(0x80000000), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x335BE8FF), blurRadius: 24, spreadRadius: 2),
  ];

  static const List<String> backgroundLayers = [
    'assets/design/gameplay.bg.cinematic_room.1920x1080@2x.webp',
    'assets/design/gameplay.decor.light_rays.overlay.1920x1080@2x.webp',
  ];

  static const String refDir = 'codex_handoff_big_walker/reference_screens';
  static const List<String> referenceScreens = [
    '$refDir/01_settings_modal_reference.png',
    '$refDir/02_match_screen_single_token_reference.png',
    '$refDir/03_match_screen_multi_token_reference.png',
    '$refDir/04_dice_roll_state_reference.png',
    '$refDir/05_next_turn_overlay_reference.png',
    '$refDir/06_match_screen_alt_layout_reference.png',
    '$refDir/07_player_select_screen_reference.png',
    '$refDir/08_pause_menu_reference.png',
    '$refDir/09_victory_modal_reference.png',
    '$refDir/10_rules_modal_reference.png',
  ];

  static const List<Color> pawnPalette = [
    Color(0xFF6CEEFF),
    Color(0xFFFFC879),
    Color(0xFF9DE882),
    Color(0xFFF38BE9),
    Color(0xFFAFA4FF),
    Color(0xFFFF8F8F),
  ];
}
