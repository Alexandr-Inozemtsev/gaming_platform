import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import '../animations/big_walker_motion.dart';

class BigWalkerPlayerChips extends StatelessWidget {
  const BigWalkerPlayerChips({
    super.key,
    required this.participantsCount,
    required this.currentPlayerIndex,
  });

  final int participantsCount;
  final int currentPlayerIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final active = index == currentPlayerIndex;
          return AnimatedContainer(
            duration: BigWalkerMotion.turnGlow,
            curve: BigWalkerMotion.turnGlowCurve,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: active ? BigWalkerTokens.accentCyan.withOpacity(0.18) : BigWalkerTokens.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? BigWalkerTokens.accentCyan : BigWalkerTokens.cardBorder),
              boxShadow: active
                  ? [
                      BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.38), blurRadius: 18, spreadRadius: 1),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(BigWalkerTokens.accentCyan, BigWalkerTokens.accentAmber, index / 6) ?? BigWalkerTokens.accentCyan,
                        Colors.white,
                      ],
                    ),
                    border: Border.all(color: Colors.black.withOpacity(0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Text(
                  index == 0 ? 'You' : 'Player ${index + 1}',
                  style: TextStyle(
                    color: BigWalkerTokens.textPrimary,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.flash_on_rounded, size: 14, color: BigWalkerTokens.accentAmber),
                ],
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: participantsCount,
      ),
    );
  }
}
