import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import '../animations/big_walker_motion.dart';

class BigWalkerActionPanel extends StatelessWidget {
  const BigWalkerActionPanel({
    super.key,
    required this.isRollingDice,
    required this.diceValue,
    required this.onRollDice,
  });

  final bool isRollingDice;
  final int diceValue;
  final VoidCallback onRollDice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BigWalkerTokens.card,
        borderRadius: BorderRadius.circular(BigWalkerTokens.panelRadius),
        border: Border.all(color: BigWalkerTokens.cardBorder),
        boxShadow: [
          BoxShadow(color: BigWalkerTokens.accentAmber.withOpacity(0.18), blurRadius: BigWalkerTokens.panelBlurGlow),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isRollingDice ? null : onRollDice,
              child: AnimatedContainer(
                duration: BigWalkerMotion.dicePulse,
                curve: BigWalkerMotion.dicePulseCurve,
                height: BigWalkerTokens.actionButtonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: isRollingDice
                        ? [BigWalkerTokens.bgSoft, BigWalkerTokens.bgMid]
                        : [BigWalkerTokens.accentAmber.withOpacity(0.92), const Color(0xFFE39E3C)],
                  ),
                  boxShadow: isRollingDice
                      ? const []
                      : [
                          BoxShadow(color: BigWalkerTokens.accentAmber.withOpacity(0.4), blurRadius: 16),
                        ],
                ),
                alignment: Alignment.center,
                child: Text(
                  isRollingDice ? 'Кубик крутится…' : 'Бросить кубик',
                  style: TextStyle(
                    color: isRollingDice ? BigWalkerTokens.textSecondary : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedScale(
            scale: isRollingDice ? 1.12 : 1,
            duration: BigWalkerMotion.dicePulse,
            curve: BigWalkerMotion.dicePulseCurve,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.22), blurRadius: 14),
                ],
              ),
              child: Text(
                '$diceValue',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 24),
              ),
            ),
          )
        ],
      ),
    );
  }
}
