import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

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
  });

  final int participantsCount;
  final ValueChanged<int> onParticipantsCountChanged;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onQuickChat;
  final int currentPlayerIndex;
  final int turnNumber;
  final int diceValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BigWalkerTokens.card,
        borderRadius: BorderRadius.circular(BigWalkerTokens.panelRadius),
        border: Border.all(color: BigWalkerTokens.cardBorder),
        boxShadow: [
          BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.12), blurRadius: BigWalkerTokens.panelBlurGlow),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Большая бродилка', style: TextStyle(color: BigWalkerTokens.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Ход $turnNumber • Игрок ${currentPlayerIndex + 1} • d$diceValue', style: const TextStyle(color: BigWalkerTokens.textSecondary, fontSize: 12)),
            ],
          ),
          const Spacer(),
          _StepperButton(icon: Icons.remove, onTap: () => onParticipantsCountChanged((participantsCount - 1).clamp(2, 6))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('$participantsCount', style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700)),
          ),
          _StepperButton(icon: Icons.add, onTap: () => onParticipantsCountChanged((participantsCount + 1).clamp(2, 6))),
          const SizedBox(width: 10),
          _CircleIcon(icon: Icons.videocam_rounded, onTap: onToggleVideo),
          const SizedBox(width: 6),
          _CircleIcon(icon: Icons.mic_rounded, onTap: onToggleMic),
          const SizedBox(width: 6),
          _CircleIcon(icon: Icons.chat_bubble_outline_rounded, onTap: onQuickChat),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: BigWalkerTokens.bgSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: BigWalkerTokens.cardBorder),
        ),
        child: Icon(icon, size: 16, color: BigWalkerTokens.textPrimary),
      ),
    );
  }
}
