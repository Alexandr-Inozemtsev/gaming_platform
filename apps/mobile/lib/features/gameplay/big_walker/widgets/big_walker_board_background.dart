part of '../../../../games/big_walker/big_walker_board.dart';

class _BigWalkerBoardBackground extends StatelessWidget {
  const _BigWalkerBoardBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: BigWalkerTokens.boardAuraGradient,
      ),
      child: CustomPaint(
        painter: _BoardAtmospherePainter(),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

class _BoardAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tableLight = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.28),
        radius: 1.0,
        colors: [Color(0x2EA7E6FF), Color(0x12000000), Colors.transparent],
        stops: [0.0, 0.52, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, tableLight);

    final brush = Paint()..style = PaintingStyle.fill;
    const streaks = <({double y, double h, double opacity})>[
      (y: 0.08, h: 0.06, opacity: 0.07),
      (y: 0.24, h: 0.04, opacity: 0.06),
      (y: 0.46, h: 0.05, opacity: 0.05),
      (y: 0.69, h: 0.07, opacity: 0.06),
      (y: 0.87, h: 0.04, opacity: 0.05),
    ];

    for (final streak in streaks) {
      brush.color = const Color(0xFF75C4E8).withOpacity(streak.opacity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.height * streak.y, size.width, size.height * streak.h),
          const Radius.circular(18),
        ),
        brush,
      );
    }

    final vignette = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, 0),
        radius: 1.15,
        colors: [Colors.transparent, Color(0x6B05080F)],
        stops: [0.58, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
