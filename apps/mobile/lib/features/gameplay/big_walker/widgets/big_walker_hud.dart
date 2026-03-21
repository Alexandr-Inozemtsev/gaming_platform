import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import '../animations/big_walker_motion.dart';

class BigWalkerHud extends StatelessWidget {
  const BigWalkerHud({
    super.key,
    required this.participantsCount,
    required this.onParticipantsCountChanged,
    required this.onToggleVideo,
    required this.onToggleMic,
    required this.onQuickChat,
    required this.currentPlayerIndex,
    required this.turnNumber,
    required this.diceValue,
    required this.onOpenPause,
  });

  final int participantsCount;
  final ValueChanged<int> onParticipantsCountChanged;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onQuickChat;
  final int currentPlayerIndex;
  final int turnNumber;
  final int diceValue;
  final VoidCallback onOpenPause;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BigWalkerTokens.card,
        borderRadius: BorderRadius.circular(BigWalkerTokens.panelRadius),
        border: Border.all(color: BigWalkerTokens.cardBorder),
        boxShadow: [
          BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.16), blurRadius: BigWalkerTokens.panelBlurGlow),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Большая бродилка', style: TextStyle(color: BigWalkerTokens.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: BigWalkerMotion.turnGlow,
                  switchInCurve: BigWalkerMotion.turnGlowCurve,
                  switchOutCurve: BigWalkerMotion.turnGlowCurve,
                  child: _TurnPill(
                    key: ValueKey('turn-$currentPlayerIndex-$turnNumber-$diceValue'),
                    label: 'Ход $turnNumber · Игрок ${currentPlayerIndex + 1} · d$diceValue',
                  ),
                ),
              ],
            ),
          ),
          _StepperButton(icon: Icons.remove, onTap: () => onParticipantsCountChanged((participantsCount - 1).clamp(2, 6))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const Text('Игроки', style: TextStyle(color: BigWalkerTokens.textSecondary, fontSize: 10)),
                Text('$participantsCount', style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ),
          _StepperButton(icon: Icons.add, onTap: () => onParticipantsCountChanged((participantsCount + 1).clamp(2, 6))),
          const SizedBox(width: 12),
          _CircleIcon(icon: Icons.videocam_rounded, onTap: onToggleVideo),
          const SizedBox(width: 6),
          _CircleIcon(icon: Icons.mic_rounded, onTap: onToggleMic),
          const SizedBox(width: 6),
          _CircleIcon(icon: Icons.chat_bubble_outline_rounded, onTap: onQuickChat),
          const SizedBox(width: 6),
          _CircleIcon(icon: Icons.pause_rounded, onTap: onOpenPause),
        ],
      ),
    );
  }
}

class _TurnPill extends StatelessWidget {
  const _TurnPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: BigWalkerTokens.accentCyan.withOpacity(0.16),
        border: Border.all(color: BigWalkerTokens.accentCyan.withOpacity(0.7)),
      ),
      child: Text(label, style: const TextStyle(color: BigWalkerTokens.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BigWalkerTokens.iconButtonSize),
        child: Ink(
          width: BigWalkerTokens.iconButtonSize,
          height: BigWalkerTokens.iconButtonSize,
          decoration: BoxDecoration(
            color: BigWalkerTokens.bgSoft,
            borderRadius: BorderRadius.circular(BigWalkerTokens.iconButtonSize),
            border: Border.all(color: BigWalkerTokens.cardBorder),
          ),
          child: Icon(icon, size: 18, color: BigWalkerTokens.textPrimary),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: BigWalkerTokens.bgSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: BigWalkerTokens.cardBorder),
          ),
          child: Icon(icon, size: 16, color: BigWalkerTokens.textPrimary),
        ),
      ),
    );
  }
}
