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
    final hasPlayer = playersHere.isNotEmpty;
    final highlight = isActivePath || hasPlayer;

    final markerColor = switch (tileStyle) {
      BigWalkerTileStyle.normal => BigWalkerTokens.accentCyan,
      BigWalkerTileStyle.bonus => BigWalkerTokens.accentAmber,
      BigWalkerTileStyle.risk => const Color(0xFFFFA07A),
    };

    return IgnorePointer(
      child: AnimatedContainer(
        duration: BigWalkerMotion.cellStep,
        margin: const EdgeInsets.all(BigWalkerTokens.cellGap),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BigWalkerTokens.cellRadius),
          color: highlight ? markerColor.withOpacity(0.12) : Colors.transparent,
          border: Border.all(
            color: highlight ? markerColor.withOpacity(0.85) : Colors.transparent,
            width: highlight ? 1.6 : 0,
          ),
          boxShadow: [
            if (highlight)
              BoxShadow(
                color: markerColor.withOpacity(0.28),
                blurRadius: 10,
                spreadRadius: 0.4,
              ),
          ],
        ),
      ),
    );
  }
}
