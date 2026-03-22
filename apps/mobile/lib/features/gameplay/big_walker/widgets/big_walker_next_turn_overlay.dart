import 'package:flutter/material.dart';

import '../../../../theme/game/big_walker_tokens.dart';

class BigWalkerNextTurnOverlay extends StatelessWidget {
  const BigWalkerNextTurnOverlay({super.key, required this.playerIndex});

  final int playerIndex;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: BigWalkerTokens.panel.withOpacity(0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: BigWalkerTokens.accentCyan),
              boxShadow: const [BoxShadow(color: Color(0xAA53E6FF), blurRadius: 24, spreadRadius: 2)],
            ),
            child: Text(
              'Ход игрока ${playerIndex + 1}',
              style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
