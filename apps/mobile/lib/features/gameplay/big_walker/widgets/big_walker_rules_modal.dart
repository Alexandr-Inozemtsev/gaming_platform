import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import 'big_walker_modal_shell.dart';

class BigWalkerRulesModal extends StatelessWidget {
  const BigWalkerRulesModal({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return BigWalkerModalShell(
      title: 'Правила Big Walker',
      subtitle: 'Классический режим путешествия по магическому маршруту',
      icon: Icons.menu_book_rounded,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RuleLine(index: 1, text: 'Игроки ходят по очереди. Порядок отмечен в HUD и на чипах.'),
          SizedBox(height: 8),
          _RuleLine(index: 2, text: 'Нажмите «Бросить кубик», чтобы получить значение от 1 до 6.'),
          SizedBox(height: 8),
          _RuleLine(index: 3, text: 'Фишка движется пошагово по маршруту на выпавшее число клеток.'),
          SizedBox(height: 8),
          _RuleLine(index: 4, text: 'Побеждает игрок, достигший последней клетки раньше остальных.'),
        ],
      ),
      actions: [BigWalkerModalButton(label: 'Закрыть', onTap: onClose, primary: true, icon: Icons.check_rounded)],
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BigWalkerTokens.accentCyan.withOpacity(0.18),
            border: Border.all(color: BigWalkerTokens.accentCyan.withOpacity(0.6)),
          ),
          child: Text('$index', style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: BigWalkerTokens.textSecondary, height: 1.25))),
      ],
    );
  }
}
