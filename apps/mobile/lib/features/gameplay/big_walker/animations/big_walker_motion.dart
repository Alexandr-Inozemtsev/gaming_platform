import 'package:flutter/material.dart';

class BigWalkerMotion {
  static const Duration dicePulse = Duration(milliseconds: 120);
  static const Duration pawnMove = Duration(milliseconds: 300);
  static const Duration turnGlow = Duration(milliseconds: 220);

  static const Curve dicePulseCurve = Curves.easeOutCubic;
  static const Curve pawnMoveCurve = Curves.easeOutCubic;
  static const Curve turnGlowCurve = Curves.easeInOutCubicEmphasized;
}
