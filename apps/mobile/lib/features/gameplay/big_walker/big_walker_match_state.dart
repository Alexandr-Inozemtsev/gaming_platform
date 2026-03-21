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
    required this.turnNumber,
    required this.activePathIndex,
    required this.winnerIndex,
    required this.isStarted,
  });

  final String title;
  final int participantsCount;
  final List<int> walkerPositions;
  final int currentPlayerIndex;
  final int diceValue;
  final bool isRollingDice;
  final int turnNumber;
  final int? activePathIndex;
  final int? winnerIndex;
  final bool isStarted;
}

@immutable
class BigWalkerMatchActions {
  const BigWalkerMatchActions({
    required this.onParticipantsCountChanged,
    required this.onRollDice,
    required this.onToggleVideo,
    required this.onToggleMic,
    required this.onQuickChat,
    required this.onStartMatch,
  });

  final ValueChanged<int> onParticipantsCountChanged;
  final VoidCallback onRollDice;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onQuickChat;
  final VoidCallback onStartMatch;
}

@immutable
class BigWalkerViewModel {
  const BigWalkerViewModel({required this.state, required this.actions});

  final BigWalkerMatchViewState state;
  final BigWalkerMatchActions actions;
}
