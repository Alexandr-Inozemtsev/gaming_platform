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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. Игроки по очереди бросают кубик.', style: TextStyle(color: BigWalkerTokens.textSecondary)),
          SizedBox(height: 6),
          Text('2. Фишка движется на выпавшее число клеток.', style: TextStyle(color: BigWalkerTokens.textSecondary)),
          SizedBox(height: 6),
          Text('3. Первый, кто дойдет до финиша, побеждает.', style: TextStyle(color: BigWalkerTokens.textSecondary)),
        ],
      ),
      actions: [BigWalkerModalButton(label: 'Закрыть', onTap: onClose, primary: true)],
    );
  }
}
