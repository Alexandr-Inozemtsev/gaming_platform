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

  // Core palette
  static const Color bgDeep = Color(0xFF090F1F);
  static const Color bgMid = Color(0xFF101A31);
  static const Color bgSoft = Color(0xFF15233E);
  static const Color card = Color(0xCC111B33);
  static const Color cardBorder = Color(0x3349B2FF);
  static const Color accentCyan = Color(0xFF6EE7FF);
  static const Color accentAmber = Color(0xFFFFC971);
  static const Color textPrimary = Color(0xFFF2F7FF);
  static const Color textSecondary = Color(0xFFB7C7DE);

  // Scene layers
  static const double sceneRadius = 24;
  static const double scenePadding = 12;
  static const double tableRadius = 26;
  static const double tableHeightFactor = 0.74;

  // Board
  static const double boardRadius = 22;
  static const double boardBorderWidth = 2;
  static const double cellGap = 3;
  static const double cellRadius = 10;
  static const double pawnRadius = 9;
  static const double pawnStrokeWidth = 1.5;

  static const Color boardGradientStart = Color(0xFF142948);
  static const Color boardGradientMid = Color(0xFF1B3D63);
  static const Color boardGradientEnd = Color(0xFF102742);
  static const Color boardBorder = Color(0xA66EE7FF);

  static const Color specialCellColor = Color(0xFF33598C);
  static const Color evenCellColor = Color(0xFF1E365A);
  static const Color oddCellColor = Color(0xFF24406A);
  static const Color specialCellIcon = Color(0xFFFFD166);
  static const Color startCellColor = Color(0xFF3BD48E);
  static const Color finishCellColor = Color(0xFFF8A73A);
  static const Color activePathGlow = Color(0xAA6EE7FF);

  // HUD / action panel
  static const double panelRadius = 16;
  static const double panelBlurGlow = 20;
  static const double iconButtonSize = 38;
  static const double actionButtonHeight = 54;

  static const List<String> backgroundLayers = [
    'assets/design/gameplay.bg.cinematic_room.1920x1080@2x.webp',
    'assets/design/gameplay.decor.light_rays.overlay.1920x1080@2x.webp',
  ];
}
