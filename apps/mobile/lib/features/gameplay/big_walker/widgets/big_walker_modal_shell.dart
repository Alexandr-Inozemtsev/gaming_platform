import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerModalShell extends StatelessWidget {
  const BigWalkerModalShell({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.66),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.96, end: 1),
            duration: BigWalkerTokens.modal,
            curve: Curves.easeOutBack,
            builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              width: 520,
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xE61B2E4A), Color(0xE60D182B)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: BigWalkerTokens.panelBorderActive),
                boxShadow: [
                  ...BigWalkerTokens.panelShadow,
                  const BoxShadow(color: Color(0x774FE8FF), blurRadius: 28, spreadRadius: 1),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Color(0xFF223D60), Color(0xFF14263E)]),
                            border: Border.all(color: BigWalkerTokens.panelBorder),
                          ),
                          child: Icon(icon, color: BigWalkerTokens.accentAmber, size: 18),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 24),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: const TextStyle(color: BigWalkerTokens.textSecondary, fontSize: 13)),
                  ],
                  const SizedBox(height: 14),
                  child,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: actions),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BigWalkerModalButton extends StatelessWidget {
  const BigWalkerModalButton({super.key, required this.label, required this.onTap, this.primary = false, this.icon});

  final String label;
  final VoidCallback onTap;
  final bool primary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
          boxShadow: primary ? BigWalkerTokens.buttonGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: primary ? Colors.black : BigWalkerTokens.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(color: primary ? Colors.black : BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
