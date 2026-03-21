import 'package:flutter/foundation.dart';

@immutable
class BigWalkerMatchViewState {
  const BigWalkerMatchViewState({
    required this.title,
    required this.participantsCount,
    required this.walkerPositions,
    required this.currentPlayerIndex,
    required this.diceValue,
    required this.isRollingDice,
  });

  final String title;
  final int participantsCount;
  final List<int> walkerPositions;
  final int currentPlayerIndex;
  final int diceValue;
  final bool isRollingDice;
}

@immutable
class BigWalkerMatchActions {
  const BigWalkerMatchActions({
    required this.onParticipantsCountChanged,
    required this.onRollDice,
    required this.onToggleVideo,
    required this.onToggleMic,
    required this.onQuickChat,
  });

  final ValueChanged<int> onParticipantsCountChanged;
  final VoidCallback onRollDice;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onQuickChat;
}
