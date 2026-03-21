import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

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
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final active = index == currentPlayerIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: active ? BigWalkerTokens.accentCyan.withOpacity(0.16) : BigWalkerTokens.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? BigWalkerTokens.accentCyan : BigWalkerTokens.cardBorder),
              boxShadow: active
                  ? [
                      BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.35), blurRadius: 16, spreadRadius: 1),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: Color.lerp(BigWalkerTokens.accentCyan, BigWalkerTokens.accentAmber, index / 6),
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Text(
                  index == 0 ? 'You' : 'Player ${index + 1}',
                  style: TextStyle(
                    color: BigWalkerTokens.textPrimary,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
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
