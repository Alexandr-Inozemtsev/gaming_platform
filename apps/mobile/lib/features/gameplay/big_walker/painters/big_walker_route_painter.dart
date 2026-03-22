import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import '../model/board_path.dart';

class BigWalkerRoutePainter extends CustomPainter {
  const BigWalkerRoutePainter({required this.path, required this.activePathIndex});

  final BigWalkerBoardPath path;
  final int? activePathIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / BigWalkerTokens.cols;
    final cellH = size.height / BigWalkerTokens.rows;

    final route = Path();
    for (int i = 0; i < path.nodes.length; i += 1) {
      final point = path.nodes[i].toBoardOffset(cellWidth: cellW, cellHeight: cellH);
      if (i == 0) {
        route.moveTo(point.dx, point.dy);
      } else {
        route.lineTo(point.dx, point.dy);
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

    canvas.drawPath(route, routeGlow);
    canvas.drawPath(route, routeCore);
    canvas.drawPath(route, routeSpark);

    if (activePathIndex != null) {
      final activeNode = path.nodeForRouteIndex(activePathIndex!);
      final activeCenter = activeNode.toBoardOffset(cellWidth: cellW, cellHeight: cellH);

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
    return oldDelegate.activePathIndex != activePathIndex || oldDelegate.path != path;
  }
}
