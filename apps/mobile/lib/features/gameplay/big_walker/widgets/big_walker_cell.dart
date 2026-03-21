part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerCell extends StatelessWidget {
  const _BigWalkerCell({required this.index, required this.playersHere});

  final int index;
  final List<int> playersHere;

  @override
  Widget build(BuildContext context) {
    final isSpecial = index % 7 == 0;
    final baseColor = isSpecial
        ? BigWalkerTokens.specialCellColor
        : (index.isEven ? BigWalkerTokens.evenCellColor : BigWalkerTokens.oddCellColor);

    return Container(
      margin: const EdgeInsets.all(BigWalkerTokens.cellGap),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(BigWalkerTokens.cellRadius),
        border: Border.all(color: playersHere.isNotEmpty ? AppColors.primaryFig : AppColors.strokeSoft),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 5,
            top: 3,
            child: Text('${index + 1}', style: AppTypography.caption.copyWith(color: Colors.white70)),
          ),
          if (isSpecial)
            const Center(
              child: Icon(Icons.auto_awesome_rounded, size: 14, color: BigWalkerTokens.specialCellIcon),
            ),
        ],
      ),
    );
  }
}
