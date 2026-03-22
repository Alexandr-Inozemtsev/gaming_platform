part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerPawn extends StatelessWidget {
  const _BigWalkerPawn({
    super.key,
    required this.playerIndex,
    required this.routeIndex,
    required this.cellSize,
    required this.path,
    required this.active,
  });

  final int playerIndex;
  final int routeIndex;
  final double cellSize;
  final BigWalkerBoardPath path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: routeIndex.toDouble()),
      duration: BigWalkerMotion.pawnMove,
      curve: BigWalkerMotion.pawnMoveCurve,
      builder: (context, value, _) {
        final interpolatedRouteIndex = value.round();
        final node = path.nodeForRouteIndex(interpolatedRouteIndex);
        final center = node.toBoardOffset(cellWidth: cellSize, cellHeight: cellSize);

        final ringRadius = BigWalkerTokens.pawnRadius * 1.5;
        final offsetX = ringRadius * 0.24 * ((playerIndex % 3) - 1);
        final offsetY = ringRadius * 0.24 * ((playerIndex ~/ 3) - 0.5);
        final color = BigWalkerTokens.pawnPalette[playerIndex % BigWalkerTokens.pawnPalette.length];

        return Positioned(
          left: center.dx - BigWalkerTokens.pawnRadius + offsetX,
          top: center.dy - BigWalkerTokens.pawnRadius + offsetY,
          child: AnimatedContainer(
            duration: BigWalkerMotion.turnGlow,
            width: BigWalkerTokens.pawnRadius * 2,
            height: BigWalkerTokens.pawnRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white, color, color.withOpacity(0.75)],
                stops: const [0.08, 0.52, 1],
              ),
              border: Border.all(color: Colors.black.withOpacity(0.48), width: BigWalkerTokens.pawnStrokeWidth),
              boxShadow: [
                BoxShadow(
                  color: active ? BigWalkerTokens.accentCyan.withOpacity(0.7) : Colors.black.withOpacity(0.45),
                  blurRadius: active ? 18 : 8,
                  spreadRadius: active ? 1.5 : 0,
                  offset: const Offset(0, 2),
                ),
                if (active) BoxShadow(color: color.withOpacity(0.52), blurRadius: 18, spreadRadius: 0.8),
              ],
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (active)
                  Container(
                    width: BigWalkerTokens.pawnRadius * 2.2,
                    height: BigWalkerTokens.pawnRadius * 2.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
                    ),
                  ),
                Text('${playerIndex + 1}', style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        );
      },
    );
  }
}
