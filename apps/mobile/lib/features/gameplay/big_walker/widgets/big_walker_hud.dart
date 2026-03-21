import 'package:flutter/material.dart';

import '../../../../theme/tokens.dart';
import '../animations/big_walker_motion.dart';

class BigWalkerHud extends StatelessWidget {
  const BigWalkerHud({
    super.key,
    required this.isRollingDice,
    required this.diceValue,
    required this.onRollDice,
    required this.onToggleVideo,
    required this.onToggleMic,
    required this.onQuickChat,
  });

  final bool isRollingDice;
  final int diceValue;
  final VoidCallback onRollDice;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onQuickChat;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isRollingDice ? null : onRollDice,
                icon: const Icon(Icons.casino_rounded),
                label: Text(isRollingDice ? 'Бросаем...' : 'Бросить кубик'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedScale(
              scale: isRollingDice ? 1.25 : 1,
              duration: BigWalkerMotion.dicePulse,
              curve: BigWalkerMotion.dicePulseCurve,
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$diceValue', style: AppTypography.h2.copyWith(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 52),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Column(
            children: [
              _MiniIconButton(icon: Icons.videocam_rounded, onTap: onToggleVideo),
              const SizedBox(height: 6),
              _MiniIconButton(icon: Icons.mic_rounded, onTap: onToggleMic),
              const SizedBox(height: 6),
              _MiniIconButton(icon: Icons.chat_bubble_outline_rounded, onTap: onQuickChat),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: AppColors.bgElevated1.withOpacity(0.8), borderRadius: BorderRadius.circular(22)),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
