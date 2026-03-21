part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerBoardBackground extends StatelessWidget {
  const _BigWalkerBoardBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.1,
              colors: [Color(0x552EC5B6), Colors.transparent],
            ),
          ),
        ),
        ...BigWalkerTokens.backgroundLayers.map(
          (assetPath) => Opacity(
            opacity: 0.16,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}
