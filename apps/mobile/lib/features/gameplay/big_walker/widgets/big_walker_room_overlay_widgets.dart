import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerRoomOverlayPanel extends StatelessWidget {
  const BigWalkerRoomOverlayPanel({
    super.key,
    required this.child,
    this.compact = false,
  });

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? BigWalkerTokens.space10 : BigWalkerTokens.space12),
      decoration: BoxDecoration(
        gradient: BigWalkerTokens.overlayPanelGradient,
        borderRadius: BorderRadius.circular(compact ? BigWalkerTokens.cardRadius : BigWalkerTokens.panelRadius),
        border: Border.all(color: BigWalkerTokens.panelBorderActive.withOpacity(0.92)),
        boxShadow: [
          ...BigWalkerTokens.overlayPanelShadow,
          const BoxShadow(color: Color(0x6658E8FF), blurRadius: 14, spreadRadius: 0.4),
        ],
      ),
      child: child,
    );
  }
}

class BigWalkerRoomOverlayButton extends StatelessWidget {
  const BigWalkerRoomOverlayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
    this.icon,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool danger;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gradient = danger
        ? BigWalkerTokens.overlayDangerGradient
        : primary
            ? BigWalkerTokens.rollButtonGradient
            : BigWalkerTokens.panelGradient;
    final textColor = (danger || primary) ? Colors.black : BigWalkerTokens.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BigWalkerTokens.cardRadius),
      child: Ink(
        height: compact ? 36 : 40,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BigWalkerTokens.cardRadius),
          gradient: gradient,
          border: Border.all(
            color: danger ? Colors.transparent : BigWalkerTokens.panelBorder.withOpacity(0.85),
          ),
          boxShadow: danger || primary ? BigWalkerTokens.buttonGlow : BigWalkerTokens.overlayButtonShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: compact ? 14 : 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
