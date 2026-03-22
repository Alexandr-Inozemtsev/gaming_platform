import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import 'big_walker_modal_shell.dart';

class BigWalkerSettingsModal extends StatelessWidget {
  const BigWalkerSettingsModal({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return BigWalkerModalShell(
      title: 'Настройки стола',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Кинематографический свет: включен', style: TextStyle(color: BigWalkerTokens.textSecondary)),
          SizedBox(height: 6),
          Text('• Подсказки хода: включены', style: TextStyle(color: BigWalkerTokens.textSecondary)),
          SizedBox(height: 6),
          Text('• Скорость анимаций: стандарт', style: TextStyle(color: BigWalkerTokens.textSecondary)),
        ],
      ),
      actions: [BigWalkerModalButton(label: 'Готово', onTap: onClose, primary: true)],
    );
  }
}
