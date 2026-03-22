import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
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
    final winnerColor = BigWalkerTokens.pawnPalette[winnerIndex % BigWalkerTokens.pawnPalette.length];
    return BigWalkerModalShell(
      title: 'Победа игрока ${winnerIndex + 1}',
      subtitle: 'Финиш достигнут за $turnNumber ходов. Легенда стола определена!',
      icon: Icons.emoji_events_rounded,
      child: BigWalkerModalCard(
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BigWalkerTokens.cardRadius - 2),
            gradient: LinearGradient(colors: [winnerColor.withOpacity(0.36), BigWalkerTokens.bgSoft.withOpacity(0.52)]),
            border: Border.all(color: winnerColor.withOpacity(0.8)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.white, winnerColor]),
                  boxShadow: [BoxShadow(color: winnerColor.withOpacity(0.5), blurRadius: 14)],
                ),
                alignment: Alignment.center,
                child: Text('${winnerIndex + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Партия завершена. Запустите новую игру, чтобы снова сразиться за титул главного странника.',
                  style: TextStyle(color: BigWalkerTokens.textPrimary, height: 1.25),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [BigWalkerModalButton(label: 'Новая партия', primary: true, onTap: onRestart, icon: Icons.replay_rounded)],
    );
  }
}
