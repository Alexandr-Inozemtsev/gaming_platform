import 'package:flutter/material.dart';

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
      subtitle: 'Продолжите матч или откройте доп. меню',
      child: Row(
        children: [
          Expanded(child: BigWalkerModalButton(label: 'Правила', onTap: onOpenRules)),
          Expanded(child: BigWalkerModalButton(label: 'Настройки', onTap: onOpenSettings)),
        ],
      ),
      actions: [BigWalkerModalButton(label: 'Продолжить', onTap: onResume, primary: true)],
    );
  }
}
