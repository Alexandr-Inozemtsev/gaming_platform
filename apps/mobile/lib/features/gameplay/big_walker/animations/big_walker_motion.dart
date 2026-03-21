import 'package:flutter/material.dart';

class BigWalkerMotion {
  static const Duration dicePulse = Duration(milliseconds: 120);
  static const Duration pawnMove = Duration(milliseconds: 280);
  static const Duration turnGlow = Duration(milliseconds: 220);
  static const Duration cellStep = Duration(milliseconds: 280);
  static const Duration winnerModal = Duration(milliseconds: 260);

  static const Curve dicePulseCurve = Curves.easeOutCubic;
  static const Curve pawnMoveCurve = Curves.easeOutCubic;
  static const Curve turnGlowCurve = Curves.easeInOutCubicEmphasized;
  static const Curve winnerModalCurve = Curves.easeOutBack;
}
