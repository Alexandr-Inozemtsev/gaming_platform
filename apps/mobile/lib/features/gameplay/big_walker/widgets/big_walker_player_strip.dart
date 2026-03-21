import 'package:flutter/material.dart';

import '../../../../shared/ui/ui_kit.dart';
import '../../../../theme/tokens.dart';

class BigWalkerPlayerStrip extends StatelessWidget {
  const BigWalkerPlayerStrip({
    super.key,
    required this.participantsCount,
    required this.currentPlayerIndex,
  });

  final int participantsCount;
  final int currentPlayerIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) => PlayerSlot(
          name: index == 0 ? 'You' : 'Player ${index + 1}',
          ready: true,
          host: index == currentPlayerIndex,
        ),
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemCount: participantsCount,
      ),
    );
  }
}
