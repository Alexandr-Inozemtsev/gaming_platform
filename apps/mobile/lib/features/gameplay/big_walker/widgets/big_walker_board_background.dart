part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerBoardBackground extends StatelessWidget {
  const _BigWalkerBoardBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.4),
          radius: 1.1,
          colors: [Color(0x553AE8FF), Color(0x222A5A80), Colors.transparent],
        ),
        image: DecorationImage(
          image: const AssetImage('assets/design/gameplay.bg.cinematic_room.1920x1080@2x.webp'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.darken),
          onError: (_, __) {},
        ),
      ),
    );
  }
}
