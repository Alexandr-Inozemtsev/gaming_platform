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

  static const Color bgDeep = Color(0xFF04070F);
  static const Color bgMid = Color(0xFF091324);
  static const Color bgSoft = Color(0xFF121E34);
  static const Color roomVignette = Color(0xDD01040B);

  static const Color panel = Color(0xCC0F1B31);
  static const Color panelSoft = Color(0xCC192B47);
  static const Color panelBorder = Color(0x665FA8DA);
  static const Color panelBorderActive = Color(0xBB7AE7FF);
  static const Color panelBorderStrong = Color(0xCC9FE9FF);

  static const Color accentCyan = Color(0xFF74EDFF);
  static const Color accentCyanSoft = Color(0xFF2C9FC8);
  static const Color accentAmber = Color(0xFFFFCC7A);
  static const Color accentAmberDeep = Color(0xFFD78938);
  static const Color textPrimary = Color(0xFFF4F8FF);
  static const Color textSecondary = Color(0xFFB9CBE4);
  static const Color textMuted = Color(0xFF89A2BF);

  static const Color boardWoodTop = Color(0xFF372418);
  static const Color boardWoodBottom = Color(0xFF170E09);
  static const Color boardInnerTop = Color(0xFF162B47);
  static const Color boardInnerBottom = Color(0xFF0B1324);
  static const Color boardBorder = Color(0xCC89E7FF);
  static const Color boardPathBase = Color(0xFF25476D);
  static const Color boardPathAlt = Color(0xFF193A58);
  static const Color boardSpecial = Color(0xFF2A587E);
  static const Color boardStart = Color(0xFF39D495);
  static const Color boardFinish = Color(0xFFF5A64C);

  static const double scenePadding = 12;
  static const double sceneRadius = 24;
  static const double tableRadius = 28;
  static const double tableHeightFactor = 0.8;
  static const double boardRadius = 20;
  static const double panelRadius = 18;
  static const double modalRadius = 22;
  static const double cardRadius = 14;
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
  static const Duration modal = Duration(milliseconds: 320);
  static const Duration pulse = Duration(milliseconds: 1000);
  static const Duration emphasis = Duration(milliseconds: 700);

  static const LinearGradient roomGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDeep, bgMid],
  );

  static const LinearGradient tableGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2A1E17), Color(0xFF19120E), Color(0xFF110D0A)],
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

  static const LinearGradient overlayPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xEE1A2E4B), Color(0xE60D1A2F)],
  );

  static const LinearGradient overlayDangerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF97070), Color(0xFFD53A3A)],
  );

  static const LinearGradient overlayBackdropGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0x44020610), Color(0x9601040D)],
    stops: [0.0, 0.56, 1.0],
  );

  static const RadialGradient boardAuraGradient = RadialGradient(
    center: Alignment(0, -0.35),
    radius: 1.1,
    colors: [Color(0x553AE8FF), Color(0x222A5A80), Colors.transparent],
  );

  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: Color(0x3D5DDAFF), blurRadius: 24, spreadRadius: 1),
    BoxShadow(color: Color(0x2FB98A4D), blurRadius: 30, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> boardShadow = [
    BoxShadow(color: Color(0x80000000), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x335BE8FF), blurRadius: 24, spreadRadius: 2),
  ];

  static const List<BoxShadow> buttonGlow = [
    BoxShadow(color: Color(0x99DA9B45), blurRadius: 18),
    BoxShadow(color: Color(0x5547D5FF), blurRadius: 20, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> modalShadow = [
    BoxShadow(color: Color(0x3D5DDAFF), blurRadius: 26, spreadRadius: 1),
    BoxShadow(color: Color(0x3277A9D9), blurRadius: 38, offset: Offset(0, 14)),
  ];

  static const List<BoxShadow> emphasisGlow = [
    BoxShadow(color: Color(0x7D59E6FF), blurRadius: 18, spreadRadius: 1),
    BoxShadow(color: Color(0x665CFFC8), blurRadius: 24, spreadRadius: 1),
  ];

  static const List<BoxShadow> overlayPanelShadow = [
    BoxShadow(color: Color(0x8A030913), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x6650D6FF), blurRadius: 20, spreadRadius: 1),
  ];

  static const List<BoxShadow> overlayButtonShadow = [
    BoxShadow(color: Color(0x4D5BDBFF), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const double roomOverlayCompactHeight = 420;

  static const List<String> backgroundEnhancementLayers = <String>[];

  // Asset policy contract (tokens <-> manifest <-> runtime resolver).
  static const String defaultRasterVariant = 'raster@2x';
  static const String legacyWebpVariant = 'webp@2x';
  static const String gameplayBoardSurfaceTravelGridKey = 'gameplay.board.surface.travel_grid';
  static const String gameplayBackgroundProceduralRoomKey = 'gameplay.bg.procedural_room';
  static const String gameplayBoardSurfaceTravelGridAssetPath =
      'assets/design/gameplay.board.surface.travel_grid.1920x1080@2x.webp';

  static const LinearGradient roomAtmosphereGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1B30), Color(0x220D3555), Colors.transparent],
    stops: [0.0, 0.52, 1.0],
  );

  static const RadialGradient roomWarmSpotGradient = RadialGradient(
    center: Alignment(0, 0.72),
    radius: 1.06,
    colors: [Color(0x3DA46537), Color(0x14000000), Colors.transparent],
    stops: [0.0, 0.58, 1.0],
  );

  static const RadialGradient roomCeilingGlowGradient = RadialGradient(
    center: Alignment(0, -0.9),
    radius: 1.18,
    colors: [Color(0x3368CBFF), Color(0x0A355A94), Colors.transparent],
    stops: [0.0, 0.52, 1.0],
  );

  static const List<Color> pawnPalette = [
    Color(0xFF6CEEFF),
    Color(0xFFFFC879),
    Color(0xFF9DE882),
    Color(0xFFF38BE9),
    Color(0xFFAFA4FF),
    Color(0xFFFF8F8F),
  ];
}
