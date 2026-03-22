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

    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [BigWalkerTokens.accentAmberDeep, BigWalkerTokens.accentCyanSoft],
      ).createShader(Offset.zero & size)
      ..color = BigWalkerTokens.accentAmber;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = BigWalkerTokens.accentCyan.withOpacity(0.2);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, routePaint);

    if (activePathIndex != null) {
      final i = activePathIndex!.clamp(0, BigWalkerTokens.totalCells - 1);
      final row = i ~/ BigWalkerTokens.cols;
      final colInRow = i % BigWalkerTokens.cols;
      final col = row.isEven ? colInRow : (BigWalkerTokens.cols - 1 - colInRow);
      final activeCenter = Offset((col + 0.5) * cellW, (row + 0.5) * cellH);
      final activePaint = Paint()
        ..color = BigWalkerTokens.accentCyan.withOpacity(0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(activeCenter, 22, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BigWalkerRoutePainter oldDelegate) {
    return oldDelegate.activePathIndex != activePathIndex;
  }
}
