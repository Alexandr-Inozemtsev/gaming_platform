import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerModalShell extends StatelessWidget {
  const BigWalkerModalShell({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            width: 470,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: BigWalkerTokens.panelGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BigWalkerTokens.panelBorderActive),
              boxShadow: BigWalkerTokens.panelShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: const TextStyle(color: BigWalkerTokens.textSecondary, fontSize: 13)),
                ],
                const SizedBox(height: 14),
                child,
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BigWalkerModalButton extends StatelessWidget {
  const BigWalkerModalButton({super.key, required this.label, required this.onTap, this.primary = false});

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: primary ? BigWalkerTokens.rollButtonGradient : null,
            color: primary ? null : BigWalkerTokens.bgSoft,
            border: Border.all(color: primary ? Colors.transparent : BigWalkerTokens.panelBorder),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: primary ? Colors.black : BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
