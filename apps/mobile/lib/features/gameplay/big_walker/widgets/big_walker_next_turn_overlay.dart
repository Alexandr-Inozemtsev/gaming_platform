import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerNextTurnOverlay extends StatelessWidget {
  const BigWalkerNextTurnOverlay({super.key, required this.playerIndex});

  final int playerIndex;

  @override
  Widget build(BuildContext context) {
    final playerColor = BigWalkerTokens.pawnPalette[playerIndex % BigWalkerTokens.pawnPalette.length];
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: BigWalkerTokens.normal,
          curve: Curves.easeOutCubic,
          builder: (_, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: child),
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.98, end: 1.02),
              duration: BigWalkerTokens.pulse,
              curve: Curves.easeInOut,
              builder: (_, pulse, child) => Transform.scale(scale: pulse, child: child),
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xE61B2E4A), Color(0xE60C172B)]),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: BigWalkerTokens.accentCyan),
                  boxShadow: [
                    const BoxShadow(color: Color(0xAA53E6FF), blurRadius: 24, spreadRadius: 2),
                    BoxShadow(color: playerColor.withOpacity(0.45), blurRadius: 24, spreadRadius: 1),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Icon(Icons.diamond_rounded, color: playerColor, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ход игрока ${playerIndex + 1}',
                      style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
