import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerAtmosphere extends StatefulWidget {
  const BigWalkerAtmosphere({super.key});

  @override
  State<BigWalkerAtmosphere> createState() => _BigWalkerAtmosphereState();
}

class _BigWalkerAtmosphereState extends State<BigWalkerAtmosphere> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _ParticlePainter(t: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cyanPaint = Paint()..color = BigWalkerTokens.accentCyan.withOpacity(0.22);
    final amberPaint = Paint()..color = BigWalkerTokens.accentAmber.withOpacity(0.18);

    for (var i = 0; i < 18; i += 1) {
      final phase = (t * 2 * math.pi) + (i * 0.45);
      final x = (size.width * ((i % 6) + 1) / 7) + (math.sin(phase) * 8);
      final y = (size.height * ((i ~/ 6) + 1) / 5) - ((t * 40 + i * 6) % 38);
      final r = 1.2 + (i % 3) * 0.6;
      canvas.drawCircle(Offset(x, y), r, i.isEven ? cyanPaint : amberPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.t != t;
}
