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
    Color baseColor = isSpecial
        ? BigWalkerTokens.specialCellColor
        : (routeIndex.isEven ? BigWalkerTokens.evenCellColor : BigWalkerTokens.oddCellColor);

    if (isStart) baseColor = BigWalkerTokens.startCellColor.withOpacity(0.55);
    if (isFinish) baseColor = BigWalkerTokens.finishCellColor.withOpacity(0.55);

    return AnimatedContainer(
      duration: BigWalkerMotion.cellStep,
      margin: const EdgeInsets.all(BigWalkerTokens.cellGap),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(BigWalkerTokens.cellRadius),
        border: Border.all(
          color: isActivePath ? BigWalkerTokens.activePathGlow : (playersHere.isNotEmpty ? AppColors.primaryFig : AppColors.strokeSoft),
          width: isActivePath ? 2 : 1,
        ),
        boxShadow: [
          if (isActivePath) BoxShadow(color: BigWalkerTokens.activePathGlow.withOpacity(0.4), blurRadius: 12),
          BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 5,
            top: 3,
            child: Text('${routeIndex + 1}', style: AppTypography.caption.copyWith(color: Colors.white70)),
          ),
          if (isSpecial)
            const Center(
              child: Icon(Icons.auto_awesome_rounded, size: 14, color: BigWalkerTokens.specialCellIcon),
            ),
          if (isStart)
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text('START', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          if (isFinish)
            const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Text('FINISH', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}
