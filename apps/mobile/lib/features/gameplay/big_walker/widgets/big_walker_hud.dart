import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerHud extends StatelessWidget {
  const BigWalkerHud({
    super.key,
    required this.participantsCount,
    required this.onToggleVideo,
    required this.onToggleMic,
    required this.onQuickChat,
    required this.currentPlayerIndex,
    required this.turnNumber,
    required this.onOpenPause,
  });

  final int participantsCount;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onQuickChat;
  final int currentPlayerIndex;
  final int turnNumber;
  final VoidCallback onOpenPause;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: BigWalkerTokens.panelGradient,
        borderRadius: BorderRadius.circular(BigWalkerTokens.panelRadius),
        border: Border.all(color: BigWalkerTokens.panelBorder),
        boxShadow: BigWalkerTokens.panelShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: BigWalkerTokens.accentAmber),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Big Walker', style: TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                Text(
                  'Ход $turnNumber · Игрок ${currentPlayerIndex + 1} · Участников: $participantsCount',
                  style: const TextStyle(color: BigWalkerTokens.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          _IconOrb(icon: Icons.videocam_rounded, onTap: onToggleVideo),
          _IconOrb(icon: Icons.mic_rounded, onTap: onToggleMic),
          _IconOrb(icon: Icons.chat_bubble_outline_rounded, onTap: onQuickChat),
          _IconOrb(icon: Icons.pause_rounded, onTap: onOpenPause),
        ],
      ),
    );
  }
}

class _IconOrb extends StatelessWidget {
  const _IconOrb({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: BigWalkerTokens.iconButtonSize,
          height: BigWalkerTokens.iconButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BigWalkerTokens.bgSoft,
            border: Border.all(color: BigWalkerTokens.panelBorder),
          ),
          child: Icon(icon, color: BigWalkerTokens.textPrimary, size: 18),
        ),
      ),
    );
  }
}
