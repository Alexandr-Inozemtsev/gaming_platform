import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import 'big_walker_modal_shell.dart';

class BigWalkerPauseMenu extends StatelessWidget {
  const BigWalkerPauseMenu({super.key, required this.onResume, required this.onOpenRules, required this.onOpenSettings});

  final VoidCallback onResume;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return BigWalkerModalShell(
      title: 'Пауза',
      subtitle: 'Матч поставлен на паузу. Выберите дальнейшее действие.',
      icon: Icons.pause_circle_filled_rounded,
      child: Row(
        children: [
          Expanded(
            child: _MenuCard(
              title: 'Правила',
              subtitle: 'Краткое описание хода партии',
              icon: Icons.menu_book_rounded,
              onTap: onOpenRules,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MenuCard(
              title: 'Настройки',
              subtitle: 'Параметры визуала и атмосферы',
              icon: Icons.tune_rounded,
              onTap: onOpenSettings,
            ),
          ),
        ],
      ),
      actions: [BigWalkerModalButton(label: 'Продолжить', onTap: onResume, primary: true, icon: Icons.play_arrow_rounded)],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: BigWalkerTokens.panelGradient,
          border: Border.all(color: BigWalkerTokens.panelBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: BigWalkerTokens.accentCyan, size: 20),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: BigWalkerTokens.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
