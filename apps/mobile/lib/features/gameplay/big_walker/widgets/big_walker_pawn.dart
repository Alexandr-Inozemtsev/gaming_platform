part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerPawn extends StatefulWidget {
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
  State<_BigWalkerPawn> createState() => _BigWalkerPawnState();
}

class _BigWalkerPawnState extends State<_BigWalkerPawn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _routeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: BigWalkerMotion.pawnMove);
    _routeAnimation = AlwaysStoppedAnimation(widget.routeIndex.toDouble());
  }

  @override
  void didUpdateWidget(covariant _BigWalkerPawn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeIndex == widget.routeIndex) return;

    final begin = _routeAnimation.value;
    final end = widget.routeIndex.toDouble();
    final steps = (end - begin).abs().ceil().clamp(1, BigWalkerTokens.totalCells);
    final perStepMs = BigWalkerMotion.cellStep.inMilliseconds;
    final baseMoveMs = BigWalkerMotion.pawnMove.inMilliseconds;
    final moveDuration = Duration(milliseconds: (perStepMs * steps).clamp(baseMoveMs, perStepMs * BigWalkerTokens.totalCells));

    _controller.duration = moveDuration;
    _routeAnimation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: BigWalkerMotion.pawnMoveCurve),
    );
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringRadius = BigWalkerTokens.pawnRadius * 1.5;
    final color = BigWalkerTokens.pawnPalette[widget.playerIndex % BigWalkerTokens.pawnPalette.length];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final routeValue = _routeAnimation.value;
        final lowerRouteIndex = routeValue.floor();
        final upperRouteIndex = routeValue.ceil();
        final segmentT = (routeValue - lowerRouteIndex).clamp(0.0, 1.0);

        final lowerNode = widget.path.nodeForRouteIndex(lowerRouteIndex);
        final upperNode = widget.path.nodeForRouteIndex(upperRouteIndex);
        final lowerCenter = lowerNode.toBoardOffset(cellWidth: widget.cellSize, cellHeight: widget.cellSize);
        final upperCenter = upperNode.toBoardOffset(cellWidth: widget.cellSize, cellHeight: widget.cellSize);
        final center = Offset.lerp(lowerCenter, upperCenter, segmentT)!;

        final lowerOffset = _stackOffsetForRoute(
          routeIndex: lowerRouteIndex,
          ringRadius: ringRadius,
        );
        final upperOffset = _stackOffsetForRoute(
          routeIndex: upperRouteIndex,
          ringRadius: ringRadius,
        );
        final smoothOffset = Offset.lerp(
          lowerOffset,
          upperOffset,
          Curves.easeInOut.transform(segmentT),
        )!;

        return Positioned(
          key: ValueKey('pawn-position-${widget.playerIndex}'),
          left: center.dx - BigWalkerTokens.pawnRadius + smoothOffset.dx,
          top: center.dy - BigWalkerTokens.pawnRadius + smoothOffset.dy,
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
                  color: widget.active ? BigWalkerTokens.accentCyan.withOpacity(0.7) : Colors.black.withOpacity(0.45),
                  blurRadius: widget.active ? 18 : 8,
                  spreadRadius: widget.active ? 1.5 : 0,
                  offset: const Offset(0, 2),
                ),
                if (widget.active) BoxShadow(color: color.withOpacity(0.52), blurRadius: 18, spreadRadius: 0.8),
              ],
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.active)
                  Container(
                    width: BigWalkerTokens.pawnRadius * 2.2,
                    height: BigWalkerTokens.pawnRadius * 2.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
                    ),
                  ),
                Text(
                  '${widget.playerIndex + 1}',
                  style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Offset _stackOffsetForRoute({required int routeIndex, required double ringRadius}) {
    final slot = (widget.playerIndex + routeIndex) % 6;
    final offsetX = ringRadius * 0.24 * ((slot % 3) - 1);
    final offsetY = ringRadius * 0.24 * ((slot ~/ 3) - 0.5);
    return Offset(offsetX, offsetY);
  }
}
