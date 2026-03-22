part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerBoardBackground extends StatelessWidget {
  const _BigWalkerBoardBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: BigWalkerTokens.boardAuraGradient,
        image: DecorationImage(
          image: const AssetImage(BigWalkerTokens.roomBgAsset),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.darken),
          onError: (_, __) {},
        ),
      ),
    );
  }
}
