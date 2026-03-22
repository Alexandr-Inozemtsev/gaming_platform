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
      subtitle: 'Демо-настройки визуального окружения',
      icon: Icons.tune_rounded,
      child: const Column(
        children: [
          _SettingRow(label: 'Кинематографический свет', value: 'Включен'),
          SizedBox(height: 8),
          _SettingRow(label: 'Подсказки активного хода', value: 'Включены'),
          SizedBox(height: 8),
          _SettingRow(label: 'Скорость анимаций', value: 'Стандарт'),
        ],
      ),
      actions: [BigWalkerModalButton(label: 'Готово', onTap: onClose, primary: true, icon: Icons.check_rounded)],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: BigWalkerTokens.bgSoft.withOpacity(0.6),
        border: Border.all(color: BigWalkerTokens.panelBorder),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: BigWalkerTokens.textSecondary))),
          Text(value, style: const TextStyle(color: BigWalkerTokens.accentAmber, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
