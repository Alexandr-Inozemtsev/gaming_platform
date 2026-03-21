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
    final bool canRoll = isStarted && !isRollingDice && !hasWinner;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BigWalkerTokens.card,
        borderRadius: BorderRadius.circular(BigWalkerTokens.panelRadius),
        border: Border.all(color: BigWalkerTokens.cardBorder),
        boxShadow: [
          BoxShadow(color: BigWalkerTokens.accentAmber.withOpacity(0.22), blurRadius: BigWalkerTokens.panelBlurGlow),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: _label(canRoll),
              active: canRoll,
              onTap: canRoll ? onRollDice : onStartMatch,
            ),
          ),
          const SizedBox(width: 12),
          _DiceBadge(isRollingDice: isRollingDice, diceValue: diceValue),
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

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: BigWalkerMotion.stateFade,
        curve: BigWalkerMotion.stateFadeCurve,
        height: BigWalkerTokens.actionButtonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: widget.active
                ? [
                    BigWalkerTokens.accentAmber.withOpacity(_pressed ? 0.72 : 0.94),
                    const Color(0xFFE39E3C),
                  ]
                : [BigWalkerTokens.bgSoft, BigWalkerTokens.bgMid],
          ),
          boxShadow: widget.active
              ? [
                  BoxShadow(color: BigWalkerTokens.accentAmber.withOpacity(_pressed ? 0.2 : 0.42), blurRadius: 16),
                ]
              : const [],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            color: widget.active ? Colors.black : BigWalkerTokens.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _DiceBadge extends StatelessWidget {
  const _DiceBadge({required this.isRollingDice, required this.diceValue});

  final bool isRollingDice;
  final int diceValue;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isRollingDice ? 1 : 0),
      duration: BigWalkerMotion.diceShake,
      builder: (_, t, __) {
        final angle = math.sin(t * math.pi * 2) * 0.08;
        return Transform.rotate(
          angle: angle,
          child: AnimatedScale(
            scale: isRollingDice ? 1.15 : 1,
            duration: BigWalkerMotion.dicePulse,
            curve: BigWalkerMotion.dicePulseCurve,
            child: Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.25), blurRadius: 14),
                ],
              ),
              child: Text(
                '$diceValue',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}
