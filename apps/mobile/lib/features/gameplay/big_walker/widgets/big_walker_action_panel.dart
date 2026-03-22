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
    required this.currentPlayerIndex,
    required this.turnNumber,
  });

  final bool isRollingDice;
  final int diceValue;
  final VoidCallback onRollDice;
  final bool isStarted;
  final VoidCallback onStartMatch;
  final bool hasWinner;
  final int currentPlayerIndex;
  final int turnNumber;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isStarted ? 'Ход игрока ${currentPlayerIndex + 1} · Раунд $turnNumber' : 'Ожидание старта матча',
                  style: const TextStyle(
                    color: BigWalkerTokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _RollButton(
                  label: _label(canRoll),
                  active: canRoll || !isStarted || hasWinner,
                  onTap: canRoll ? onRollDice : onStartMatch,
                ),
              ],
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

class _DiceArea extends StatefulWidget {
  const _DiceArea({required this.isRollingDice, required this.diceValue});

  final bool isRollingDice;
  final int diceValue;

  @override
  State<_DiceArea> createState() => _DiceAreaState();
}

class _DiceAreaState extends State<_DiceArea> with SingleTickerProviderStateMixin {
  static const double _maxShakeAmplitude = 3.4;

  late final AnimationController _vfxController;

  @override
  void initState() {
    super.initState();
    _vfxController = AnimationController(vsync: this, duration: BigWalkerMotion.diceVfxLoop);
    if (widget.isRollingDice) {
      _vfxController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _DiceArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRollingDice == oldWidget.isRollingDice) return;
    if (widget.isRollingDice) {
      _vfxController.repeat();
    } else {
      _vfxController.animateTo(
        0,
        duration: BigWalkerMotion.diceVfxBurst,
        curve: BigWalkerMotion.diceVfxBurstCurve,
      );
    }
  }

  @override
  void dispose() {
    _vfxController.dispose();
    super.dispose();
  }

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
              fontSize: 9,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedBuilder(
            animation: _vfxController,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(_vfxController.value);
              final double burst = widget.isRollingDice ? (0.3 + (1 - (2 * (t - 0.5).abs()))) : 0.0;
              final double shake = widget.isRollingDice ? math.sin(_vfxController.value * math.pi * 8) * _maxShakeAmplitude : 0.0;
              final double tilt = widget.isRollingDice ? math.sin(_vfxController.value * math.pi * 10) * 0.08 : 0.0;
              final double ringOpacity =
                  widget.isRollingDice ? (0.28 + (math.sin(_vfxController.value * math.pi * 2).abs() * 0.34)) : 0.0;

              return Transform.translate(
                offset: Offset(shake, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isRollingDice)
                      Container(
                        width: 56 + (burst * 14),
                        height: 56 + (burst * 14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0x99FFE188).withOpacity(0.25 + (burst * 0.35)),
                              const Color(0x00FFE188),
                            ],
                          ),
                        ),
                      ),
                    if (widget.isRollingDice)
                      Container(
                        width: 42 + (burst * 10),
                        height: 42 + (burst * 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF70E7FF).withOpacity(ringOpacity),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xAA47DEFF).withOpacity(ringOpacity),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    Transform.rotate(
                      angle: tilt,
                      child: AnimatedScale(
                        duration: BigWalkerMotion.dicePulse,
                        curve: BigWalkerMotion.dicePulseCurve,
                        scale: widget.isRollingDice ? 1.12 : 1,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFDFEFF), Color(0xFFD6EBFF)]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x7747DEFF).withOpacity(widget.isRollingDice ? 0.85 : 0.5),
                                blurRadius: widget.isRollingDice ? 16 : 10,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${widget.diceValue}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
