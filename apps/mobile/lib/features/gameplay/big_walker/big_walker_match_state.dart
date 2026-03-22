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
    required this.overlay,
    required this.turnTransitionVisible,
    required this.transitionPlayerIndex,
    required this.settlingPlayerIndex,
    required this.pawnSettleTick,
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
  final String overlay;
  final bool turnTransitionVisible;
  final int? transitionPlayerIndex;
  final int? settlingPlayerIndex;
  final int pawnSettleTick;
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
    required this.onOpenPause,
    required this.onOpenRules,
    required this.onOpenSettings,
    required this.onCloseOverlay,
  });

  final ValueChanged<int> onParticipantsCountChanged;
  final VoidCallback onRollDice;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleMic;
  final VoidCallback onQuickChat;
  final VoidCallback onStartMatch;
  final VoidCallback onOpenPause;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenSettings;
  final VoidCallback onCloseOverlay;
}

@immutable
class BigWalkerViewModel {
  const BigWalkerViewModel({required this.state, required this.actions});

  final BigWalkerMatchViewState state;
  final BigWalkerMatchActions actions;
}
