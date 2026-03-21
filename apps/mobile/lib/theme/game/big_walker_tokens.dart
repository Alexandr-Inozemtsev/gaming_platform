import 'package:flutter/material.dart';

class BigWalkerTokens {
  static const int cols = 8;
  static const int rows = 5;
  static const int totalCells = cols * rows;

  static const double boardRadius = 22;
  static const double boardBorderWidth = 2;
  static const double cellGap = 3;
  static const double cellRadius = 10;
  static const double pawnRadius = 9;
  static const double pawnStrokeWidth = 1.5;

  static const Duration pawnMoveDuration = Duration(milliseconds: 300);
  static const Curve pawnMoveCurve = Curves.easeOutCubic;

  static const Color boardGradientStart = Color(0xFF0F2748);
  static const Color boardGradientMid = Color(0xFF173961);
  static const Color boardGradientEnd = Color(0xFF0F2748);
  static const Color boardBorder = Color(0xB36EE7FF);

  static const Color specialCellColor = Color(0xFF2E4F80);
  static const Color evenCellColor = Color(0xFF1E365A);
  static const Color oddCellColor = Color(0xFF24406A);
  static const Color specialCellIcon = Color(0xFFFFD166);

  static const List<String> backgroundLayers = [
    'assets/design/gameplay.bg.cinematic_room.1920x1080@2x.webp',
    'assets/design/gameplay.decor.light_rays.overlay.1920x1080@2x.webp',
  ];
}
