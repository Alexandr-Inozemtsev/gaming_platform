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
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: participantsCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final active = index == currentPlayerIndex;
          final color = BigWalkerTokens.pawnPalette[index % BigWalkerTokens.pawnPalette.length];
          return AnimatedContainer(
            duration: BigWalkerMotion.turnGlow,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BigWalkerTokens.chipRadius),
              gradient: active
                  ? LinearGradient(colors: [color.withOpacity(0.9), BigWalkerTokens.panelSoft])
                  : BigWalkerTokens.panelGradient,
              border: Border.all(color: active ? BigWalkerTokens.accentCyan : BigWalkerTokens.panelBorder),
              boxShadow: active ? [BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.32), blurRadius: 16)] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Colors.white, color]),
                  ),
                  alignment: Alignment.center,
                  child: Text('${index + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
                ),
                const SizedBox(width: 8),
                Text(
                  'Игрок ${index + 1}',
                  style: TextStyle(
                    color: BigWalkerTokens.textPrimary,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
