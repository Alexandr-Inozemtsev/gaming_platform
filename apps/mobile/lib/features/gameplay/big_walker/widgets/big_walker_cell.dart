part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerCell extends StatelessWidget {
  const _BigWalkerCell({
    required this.routeIndex,
    required this.playersHere,
    required this.isActivePath,
    required this.tileStyle,
  });

  final int routeIndex;
  final List<int> playersHere;
  final bool isActivePath;
  final BigWalkerTileStyle tileStyle;

  @override
  Widget build(BuildContext context) {
    final base = switch (tileStyle) {
      BigWalkerTileStyle.normal => routeIndex.isEven ? BigWalkerTokens.boardPathBase : BigWalkerTokens.boardPathAlt,
      BigWalkerTileStyle.bonus => BigWalkerTokens.boardSpecial,
      BigWalkerTileStyle.risk => const Color(0xFF6A3140),
    };

    return AnimatedContainer(
      duration: BigWalkerMotion.cellStep,
      margin: const EdgeInsets.all(BigWalkerTokens.cellGap),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base.withOpacity(0.95), base.withOpacity(0.64)],
        ),
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
          if (tileStyle == BigWalkerTileStyle.bonus)
            const Center(child: Icon(Icons.auto_awesome_rounded, size: 14, color: BigWalkerTokens.accentAmber)),
          if (tileStyle == BigWalkerTileStyle.risk)
            const Center(child: Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFFB07A))),
        ],
      ),
    );
  }
}
