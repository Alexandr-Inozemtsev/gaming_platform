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
      subtitle: 'Выберите количество игроков за столом и начните путешествие',
      icon: Icons.groups_2_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(5, (index) {
              final value = index + 2;
              final active = value == participantsCount;
              return InkWell(
                onTap: () => onParticipantsCountChanged(value),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 88,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: active
                        ? const LinearGradient(colors: [Color(0xFFFEDB94), Color(0xFFE39D47)])
                        : BigWalkerTokens.panelGradient,
                    border: Border.all(color: active ? BigWalkerTokens.accentAmber : BigWalkerTokens.panelBorder),
                    boxShadow: active ? BigWalkerTokens.buttonGlow : null,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$value',
                        style: TextStyle(color: active ? Colors.black : BigWalkerTokens.textPrimary, fontWeight: FontWeight.w800, fontSize: 24),
                      ),
                      Text(
                        value == 2 ? 'дуэлянта' : 'игроков',
                        style: TextStyle(color: active ? Colors.black87 : BigWalkerTokens.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          BigWalkerModalCard(
            child: Text(
              'Активный ход подсвечивается в HUD и на фишке. Побеждает тот, кто первым достигнет финиша.',
              style: TextStyle(color: BigWalkerTokens.textSecondary.withOpacity(0.9), fontSize: 12),
            ),
          ),
        ],
      ),
      actions: [
        BigWalkerModalButton(label: 'Начать матч', primary: true, icon: Icons.play_arrow_rounded, onTap: onStart),
      ],
    );
  }
}
