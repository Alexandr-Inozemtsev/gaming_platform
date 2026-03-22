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
    var baseColor = isSpecial
        ? BigWalkerTokens.boardSpecial
        : (routeIndex.isEven ? BigWalkerTokens.boardPathBase : BigWalkerTokens.boardPathAlt);
    if (isStart) baseColor = BigWalkerTokens.boardStart.withOpacity(0.82);
    if (isFinish) baseColor = BigWalkerTokens.boardFinish.withOpacity(0.86);

    return AnimatedContainer(
      duration: BigWalkerMotion.cellStep,
      margin: const EdgeInsets.all(BigWalkerTokens.cellGap),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(BigWalkerTokens.cellRadius),
        border: Border.all(
          color: isActivePath
              ? BigWalkerTokens.accentCyan
              : playersHere.isNotEmpty
                  ? BigWalkerTokens.accentAmber
                  : Colors.white.withOpacity(0.12),
          width: isActivePath ? 1.8 : 1,
        ),
        boxShadow: [
          if (isActivePath) BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.34), blurRadius: 14),
          BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 6,
            top: 4,
            child: Text(
              '${routeIndex + 1}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isSpecial && !isStart && !isFinish)
            const Center(child: Icon(Icons.auto_awesome_rounded, size: 14, color: BigWalkerTokens.accentAmber)),
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
