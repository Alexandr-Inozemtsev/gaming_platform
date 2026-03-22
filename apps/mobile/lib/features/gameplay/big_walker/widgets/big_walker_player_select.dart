import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';
import 'big_walker_modal_shell.dart';

class BigWalkerPlayerSelect extends StatelessWidget {
  const BigWalkerPlayerSelect({
    super.key,
    required this.participantsCount,
    required this.onParticipantsCountChanged,
    required this.onStart,
  });

  final int participantsCount;
  final ValueChanged<int> onParticipantsCountChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return BigWalkerModalShell(
      title: 'Подготовка партии',
      subtitle: 'Выберите количество героев за столом',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          5,
          (index) {
            final value = index + 2;
            final active = value == participantsCount;
            return InkWell(
              onTap: () => onParticipantsCountChanged(value),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 76,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: active ? BigWalkerTokens.rollButtonGradient : BigWalkerTokens.panelGradient,
                  border: Border.all(color: active ? BigWalkerTokens.accentAmber : BigWalkerTokens.panelBorder),
                ),
                alignment: Alignment.center,
                child: Text('$value', style: TextStyle(color: active ? Colors.black : BigWalkerTokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
              ),
            );
          },
        ),
      ),
      actions: [BigWalkerModalButton(label: 'Начать матч', primary: true, onTap: onStart)],
    );
  }
}
