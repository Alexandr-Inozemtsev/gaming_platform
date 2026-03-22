import 'package:flutter/material.dart';

import '../../../games/big_walker/big_walker_board.dart';
import '../../../theme/game/big_walker_tokens.dart';
import 'big_walker_match_state.dart';
import 'widgets/big_walker_action_panel.dart';
import 'widgets/big_walker_atmosphere.dart';
import 'widgets/big_walker_hud.dart';
import 'widgets/big_walker_next_turn_overlay.dart';
import 'widgets/big_walker_pause_menu.dart';
import 'widgets/big_walker_player_chips.dart';
import 'widgets/big_walker_player_select.dart';
import 'widgets/big_walker_rules_modal.dart';
import 'widgets/big_walker_settings_modal.dart';
import 'widgets/big_walker_victory_modal.dart';

class GameRoomScene extends StatelessWidget {
  const GameRoomScene({super.key, required this.viewModel});

  final BigWalkerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    final actions = viewModel.actions;

    return Container(
      decoration: const BoxDecoration(gradient: BigWalkerTokens.roomGradient),
      child: Stack(
        children: [
          const Positioned.fill(child: _SceneImageLayer()),
          const Positioned.fill(child: BigWalkerAtmosphere()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [Colors.transparent, BigWalkerTokens.roomVignette.withOpacity(0.85)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(BigWalkerTokens.scenePadding),
              child: Column(
                children: [
                  BigWalkerHud(
                    participantsCount: state.participantsCount,
                    onToggleVideo: actions.onToggleVideo,
                    onToggleMic: actions.onToggleMic,
                    onQuickChat: actions.onQuickChat,
                    currentPlayerIndex: state.currentPlayerIndex,
                    turnNumber: state.turnNumber,
                    onOpenPause: actions.onOpenPause,
                  ),
                  const SizedBox(height: 10),
                  BigWalkerPlayerChips(
                    participantsCount: state.participantsCount,
                    currentPlayerIndex: state.currentPlayerIndex,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 0.97,
                      heightFactor: BigWalkerTokens.tableHeightFactor,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: BigWalkerTokens.tableGradient,
                          borderRadius: BorderRadius.circular(BigWalkerTokens.tableRadius),
                          border: Border.all(color: BigWalkerTokens.panelBorder),
                          boxShadow: const [
                            BoxShadow(color: Color(0x66393525), blurRadius: 24, offset: Offset(0, 10)),
                            BoxShadow(color: Color(0x335AE8FF), blurRadius: 30),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: BigWalkerBoard(
                            participantsCount: state.participantsCount,
                            walkerPositions: state.walkerPositions,
                            activePathIndex: state.activePathIndex,
                            currentPlayerIndex: state.currentPlayerIndex,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  BigWalkerActionPanel(
                    isRollingDice: state.isRollingDice,
                    diceValue: state.diceValue,
                    onRollDice: actions.onRollDice,
                    isStarted: state.isStarted,
                    onStartMatch: actions.onStartMatch,
                    hasWinner: state.winnerIndex != null,
                  ),
                ],
              ),
            ),
          ),
          if (state.turnTransitionVisible && state.transitionPlayerIndex != null)
            BigWalkerNextTurnOverlay(playerIndex: state.transitionPlayerIndex!),
          _buildOverlay(state, actions),
        ],
      ),
    );
  }

  Widget _buildOverlay(BigWalkerMatchViewState state, BigWalkerMatchActions actions) {
    if (!state.isStarted && state.winnerIndex == null) {
      return BigWalkerPlayerSelect(
        participantsCount: state.participantsCount,
        onParticipantsCountChanged: actions.onParticipantsCountChanged,
        onStart: actions.onStartMatch,
      );
    }

    if (state.winnerIndex != null) {
      return BigWalkerVictoryModal(
        winnerIndex: state.winnerIndex!,
        turnNumber: state.turnNumber,
        onRestart: actions.onStartMatch,
      );
    }

    if (state.overlay == 'pause') {
      return BigWalkerPauseMenu(
        onResume: actions.onCloseOverlay,
        onOpenRules: actions.onOpenRules,
        onOpenSettings: actions.onOpenSettings,
      );
    }

    if (state.overlay == 'rules') {
      return BigWalkerRulesModal(onClose: actions.onCloseOverlay);
    }

    if (state.overlay == 'settings') {
      return BigWalkerSettingsModal(onClose: actions.onCloseOverlay);
    }

    return const SizedBox.shrink();
  }
}

class _SceneImageLayer extends StatelessWidget {
  const _SceneImageLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ...BigWalkerTokens.backgroundLayers.map(
          (asset) => Opacity(
            opacity: 0.24,
            child: Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        ),
      ],
    );
  }
}
