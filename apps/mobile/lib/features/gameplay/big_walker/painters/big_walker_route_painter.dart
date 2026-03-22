import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerRoutePainter extends CustomPainter {
  const BigWalkerRoutePainter({required this.activePathIndex});

  final int? activePathIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / BigWalkerTokens.cols;
    final cellH = size.height / BigWalkerTokens.rows;

    final path = Path();
    for (int i = 0; i < BigWalkerTokens.totalCells; i += 1) {
      final row = i ~/ BigWalkerTokens.cols;
      final colInRow = i % BigWalkerTokens.cols;
      final col = row.isEven ? colInRow : (BigWalkerTokens.cols - 1 - colInRow);
      final point = Offset((col + 0.5) * cellW, (row + 0.5) * cellH);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final routeGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = BigWalkerTokens.accentCyan.withOpacity(0.18);

    final routeCore = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [BigWalkerTokens.accentAmberDeep, BigWalkerTokens.accentCyanSoft],
      ).createShader(Offset.zero & size);

    final routeSpark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.18);

    canvas.drawPath(path, routeGlow);
    canvas.drawPath(path, routeCore);
    canvas.drawPath(path, routeSpark);

    if (activePathIndex != null) {
      final i = activePathIndex!.clamp(0, BigWalkerTokens.totalCells - 1);
      final row = i ~/ BigWalkerTokens.cols;
      final colInRow = i % BigWalkerTokens.cols;
      final col = row.isEven ? colInRow : (BigWalkerTokens.cols - 1 - colInRow);
      final activeCenter = Offset((col + 0.5) * cellW, (row + 0.5) * cellH);

      final activeAura = Paint()
        ..color = BigWalkerTokens.accentCyan.withOpacity(0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      final activeCore = Paint()..color = BigWalkerTokens.accentAmber.withOpacity(0.7);

      canvas.drawCircle(activeCenter, 26, activeAura);
      canvas.drawCircle(activeCenter, 6, activeCore);
    }
  }

  @override
  bool shouldRepaint(covariant BigWalkerRoutePainter oldDelegate) {
    return oldDelegate.activePathIndex != activePathIndex;
  }
}
