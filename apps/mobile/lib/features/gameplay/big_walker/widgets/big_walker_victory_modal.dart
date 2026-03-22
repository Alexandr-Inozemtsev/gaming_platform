import 'package:flutter/material.dart';

import 'big_walker_modal_shell.dart';

class BigWalkerVictoryModal extends StatelessWidget {
  const BigWalkerVictoryModal({
    super.key,
    required this.winnerIndex,
    required this.turnNumber,
    required this.onRestart,
  });

  final int winnerIndex;
  final int turnNumber;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return BigWalkerModalShell(
      title: 'Победа игрока ${winnerIndex + 1}',
      subtitle: 'Финиш достигнут за $turnNumber ходов.',
      child: const SizedBox.shrink(),
      actions: [BigWalkerModalButton(label: 'Новая партия', primary: true, onTap: onRestart)],
    );
  }
}
