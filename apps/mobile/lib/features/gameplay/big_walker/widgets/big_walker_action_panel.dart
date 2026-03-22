import 'dart:math' as math;

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
    final canRoll = isStarted && !isRollingDice && !hasWinner;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: BigWalkerTokens.panelGradient,
        borderRadius: BorderRadius.circular(BigWalkerTokens.panelRadius),
        border: Border.all(color: BigWalkerTokens.panelBorder),
        boxShadow: BigWalkerTokens.panelShadow,
      ),
      child: Row(
        children: [
          _DiceArea(isRollingDice: isRollingDice, diceValue: diceValue),
          const SizedBox(width: 12),
          Expanded(
            child: _RollButton(
              label: _label(canRoll),
              active: canRoll || !isStarted || hasWinner,
              onTap: canRoll ? onRollDice : onStartMatch,
            ),
          ),
        ],
      ),
    );
  }

  String _label(bool canRoll) {
    if (hasWinner) return 'Новая партия';
    if (!isStarted) return 'Начать матч';
    if (isRollingDice) return 'Кубик вращается...';
    return canRoll ? 'Бросить кубик' : 'Ожидание...';
  }
}

class _RollButton extends StatelessWidget {
  const _RollButton({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: BigWalkerTokens.actionButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: active ? BigWalkerTokens.rollButtonGradient : BigWalkerTokens.panelGradient,
          border: Border.all(color: active ? BigWalkerTokens.accentAmber : BigWalkerTokens.panelBorder),
          boxShadow: active ? BigWalkerTokens.buttonGlow : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: active ? Colors.black : BigWalkerTokens.textMuted, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _DiceArea extends StatelessWidget {
  const _DiceArea({required this.isRollingDice, required this.diceValue});

  final bool isRollingDice;
  final int diceValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: BigWalkerTokens.actionButtonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14253E), Color(0xFF0D172B)],
        ),
        border: Border.all(color: BigWalkerTokens.panelBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'D20 CORE',
            style: TextStyle(
              color: BigWalkerTokens.textMuted,
              fontSize: 10,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: isRollingDice ? 1 : 0),
            duration: BigWalkerMotion.diceShake,
            builder: (_, t, __) {
              return Transform.rotate(
                angle: math.sin(t * math.pi * 10) * 0.09,
                child: AnimatedScale(
                  duration: BigWalkerMotion.dicePulse,
                  curve: Curves.easeOutBack,
                  scale: isRollingDice ? 1.12 : 1,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFDFEFF), Color(0xFFD6EBFF)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Color(0x7747DEFF), blurRadius: 12)],
                    ),
                    alignment: Alignment.center,
                    child: Text('$diceValue', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
