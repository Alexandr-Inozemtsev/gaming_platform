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
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BigWalkerTokens.panelRadius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x28FFFFFF), Colors.transparent],
        ),
      ),
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
                const Row(
                  children: [
                    Text('Big Walker', style: TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                    SizedBox(width: 8),
                    _ActiveTurnPill(),
                  ],
                ),
                Text(
                  'Раунд $turnNumber · Активный: Игрок ${currentPlayerIndex + 1} · Участников: $participantsCount',
                  style: const TextStyle(color: BigWalkerTokens.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            gradient: const LinearGradient(colors: [Color(0xFF1B304E), Color(0xFF0F1E33)]),
            border: Border.all(color: BigWalkerTokens.panelBorder),
          ),
          child: Icon(icon, color: BigWalkerTokens.textPrimary, size: 18),
        ),
      ),
    );
  }
}

class _ActiveTurnPill extends StatelessWidget {
  const _ActiveTurnPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(colors: [Color(0x5536D5FF), Color(0x334FD0FF)]),
        border: Border.all(color: BigWalkerTokens.panelBorderActive.withOpacity(0.7)),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: BigWalkerTokens.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
