part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerPawn extends StatelessWidget {
  const _BigWalkerPawn({
    super.key,
    required this.playerIndex,
    required this.position,
    required this.cellSize,
  });

  final int playerIndex;
  final int position;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: position.toDouble()),
      duration: BigWalkerMotion.pawnMove,
      curve: BigWalkerMotion.pawnMoveCurve,
      builder: (context, value, _) {
        final index = value.round().clamp(0, BigWalkerTokens.totalCells - 1);
        final row = index ~/ BigWalkerTokens.cols;
        final col = index % BigWalkerTokens.cols;
        final centerX = (col * cellSize) + (cellSize / 2);
        final centerY = (row * cellSize) + (cellSize / 2);

        final ringRadius = BigWalkerTokens.pawnRadius * 1.4;
        final offsetX = ringRadius * 0.2 * ((playerIndex % 3) - 1);
        final offsetY = ringRadius * 0.2 * ((playerIndex ~/ 3) - 0.5);

        return Positioned(
          left: centerX - BigWalkerTokens.pawnRadius + offsetX,
          top: centerY - BigWalkerTokens.pawnRadius + offsetY,
          child: Container(
            width: BigWalkerTokens.pawnRadius * 2,
            height: BigWalkerTokens.pawnRadius * 2,
            decoration: BoxDecoration(
              color: Color.lerp(AppColors.primaryFig, AppColors.accentSecondary, playerIndex / 6) ?? AppColors.primaryFig,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black.withOpacity(0.35), width: BigWalkerTokens.pawnStrokeWidth),
              boxShadow: const [
                BoxShadow(color: Color(0x55000000), blurRadius: 5, offset: Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text('${playerIndex + 1}', style: const TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }
}
