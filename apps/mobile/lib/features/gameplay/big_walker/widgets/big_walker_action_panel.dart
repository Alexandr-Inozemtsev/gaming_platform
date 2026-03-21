import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import '../animations/big_walker_motion.dart';

class BigWalkerActionPanel extends StatelessWidget {
  const BigWalkerActionPanel({
    super.key,
    required this.isRollingDice,
    required this.diceValue,
    required this.onRollDice,
    required this.isStarted,
    required this.onStartMatch,
    required this.hasWinner,
  });

  final bool isRollingDice;
  final int diceValue;
  final VoidCallback onRollDice;
  final bool isStarted;
  final VoidCallback onStartMatch;
  final bool hasWinner;

  @override
  Widget build(BuildContext context) {
    final bool canRoll = isStarted && !isRollingDice && !hasWinner;
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
              onTap: canRoll ? onRollDice : onStartMatch,
              child: AnimatedContainer(
                duration: BigWalkerMotion.dicePulse,
                curve: BigWalkerMotion.dicePulseCurve,
                height: BigWalkerTokens.actionButtonHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: canRoll
                        ? [BigWalkerTokens.accentAmber.withOpacity(0.92), const Color(0xFFE39E3C)]
                        : [BigWalkerTokens.bgSoft, BigWalkerTokens.bgMid],
                  ),
                  boxShadow: canRoll
                      ? [
                          BoxShadow(color: BigWalkerTokens.accentAmber.withOpacity(0.4), blurRadius: 16),
                        ]
                      : const [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _label(canRoll),
                  style: TextStyle(
                    color: canRoll ? Colors.black : BigWalkerTokens.textSecondary,
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

  String _label(bool canRoll) {
    if (hasWinner) return 'Новая партия';
    if (!isStarted) return 'Начать матч';
    if (isRollingDice) return 'Кубик крутится…';
    return canRoll ? 'Бросить кубик' : 'Подождите...';
  }
}
