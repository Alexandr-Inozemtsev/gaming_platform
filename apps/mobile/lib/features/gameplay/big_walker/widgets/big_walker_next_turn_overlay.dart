import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import '../animations/big_walker_motion.dart';

class BigWalkerNextTurnOverlay extends StatefulWidget {
  const BigWalkerNextTurnOverlay({super.key, required this.playerIndex, this.shimmerEnabled = true});

  final int playerIndex;
  final bool shimmerEnabled;

  @override
  State<BigWalkerNextTurnOverlay> createState() => _BigWalkerNextTurnOverlayState();
}

class _BigWalkerNextTurnOverlayState extends State<BigWalkerNextTurnOverlay> with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _pulseController;

  late final Animation<double> _enterOpacity;
  late final Animation<double> _enterTranslate;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(vsync: this, duration: BigWalkerMotion.overlayEnter)..forward();
    _pulseController = AnimationController(vsync: this, duration: BigWalkerMotion.overlayLoop)..repeat(reverse: true);

    _enterOpacity = CurvedAnimation(parent: _enterController, curve: BigWalkerMotion.overlayEnterCurve);
    _enterTranslate = Tween<double>(begin: 16, end: 0).animate(_enterOpacity);

    final pulseCurve = CurvedAnimation(parent: _pulseController, curve: BigWalkerMotion.overlayLoopCurve);
    _pulseScale = Tween<double>(begin: 0.985, end: 1.03).animate(pulseCurve);
    _pulseGlow = Tween<double>(begin: 0.7, end: 1.2).animate(pulseCurve);
  }

  @override
  void dispose() {
    _enterController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerColor = BigWalkerTokens.pawnPalette[widget.playerIndex % BigWalkerTokens.pawnPalette.length];

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_enterController, _pulseController]),
        builder: (_, __) {
          final shimmerOffset = (_pulseController.value * 1.7) - 0.85;
          return Opacity(
            opacity: _enterOpacity.value,
            child: Transform.translate(
              offset: Offset(0, _enterTranslate.value),
              child: Center(
                child: Transform.scale(
                  scale: _pulseScale.value,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xE61B2E4A), Color(0xE60C172B)]),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: BigWalkerTokens.accentCyan),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xAA53E6FF).withOpacity(_pulseGlow.value),
                          blurRadius: 24,
                          spreadRadius: 1 + _pulseGlow.value,
                        ),
                        BoxShadow(
                          color: playerColor.withOpacity(0.3 + (_pulseGlow.value * 0.2)),
                          blurRadius: 28,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.rotate(
                                angle: math.pi / 4,
                                child: Icon(Icons.diamond_rounded, color: playerColor, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ход игрока ${widget.playerIndex + 1}',
                                style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ],
                          ),
                          if (widget.shimmerEnabled)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Transform.translate(
                                  offset: Offset(86 * shimmerOffset, 0),
                                  child: Transform.rotate(
                                    angle: -0.25,
                                    child: Container(
                                      width: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withOpacity(0.22),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
