part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerCell extends StatelessWidget {
  const _BigWalkerCell({
    required this.routeIndex,
    required this.playersHere,
    required this.isActivePath,
    required this.isStart,
    required this.isFinish,
  });

  final int routeIndex;
  final List<int> playersHere;
  final bool isActivePath;
  final bool isStart;
  final bool isFinish;

  @override
  Widget build(BuildContext context) {
    final isSpecial = routeIndex % 7 == 0;
    final base = isSpecial
        ? BigWalkerTokens.boardSpecial
        : (routeIndex.isEven ? BigWalkerTokens.boardPathBase : BigWalkerTokens.boardPathAlt);

    final gradientColors = isStart
        ? [BigWalkerTokens.boardStart.withOpacity(0.95), BigWalkerTokens.boardStart.withOpacity(0.6)]
        : isFinish
            ? [BigWalkerTokens.boardFinish.withOpacity(0.96), BigWalkerTokens.boardFinish.withOpacity(0.65)]
            : [base.withOpacity(0.94), base.withOpacity(0.66)];

    return AnimatedContainer(
      duration: BigWalkerMotion.cellStep,
      margin: const EdgeInsets.all(BigWalkerTokens.cellGap),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        borderRadius: BorderRadius.circular(BigWalkerTokens.cellRadius),
        border: Border.all(
          color: isActivePath
              ? BigWalkerTokens.accentCyan
              : playersHere.isNotEmpty
                  ? BigWalkerTokens.accentAmber
                  : Colors.white.withOpacity(0.14),
          width: isActivePath ? 2 : 1,
        ),
        boxShadow: [
          if (isActivePath) BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.34), blurRadius: 14),
          BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BigWalkerTokens.cellRadius),
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.6),
                  radius: 1.1,
                  colors: [
                    Colors.white.withOpacity(isActivePath ? 0.26 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 4,
            child: Text(
              '${routeIndex + 1}',
              style: TextStyle(color: Colors.white.withOpacity(0.86), fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
          if (isSpecial && !isStart && !isFinish)
            Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.28),
                  border: Border.all(color: BigWalkerTokens.accentAmber.withOpacity(0.8)),
                ),
                child: const Icon(Icons.auto_awesome_rounded, size: 12, color: BigWalkerTokens.accentAmber),
              ),
            ),
          if (isStart)
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Text('START', style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.w900)),
              ),
            ),
          if (isFinish)
            const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Text('FINISH', style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }
}
