import 'package:flutter/foundation.dart';
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
                  colors: [Colors.transparent, BigWalkerTokens.roomVignette.withOpacity(0.86)],
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
    Widget child = const SizedBox.shrink();

    if (!state.isStarted && state.winnerIndex == null) {
      child = BigWalkerPlayerSelect(
        participantsCount: state.participantsCount,
        onParticipantsCountChanged: actions.onParticipantsCountChanged,
        onStart: actions.onStartMatch,
      );
    } else if (state.winnerIndex != null) {
      child = BigWalkerVictoryModal(
        winnerIndex: state.winnerIndex!,
        turnNumber: state.turnNumber,
        onRestart: actions.onStartMatch,
      );
    } else if (state.overlay == 'pause') {
      child = BigWalkerPauseMenu(
        onResume: actions.onCloseOverlay,
        onOpenRules: actions.onOpenRules,
        onOpenSettings: actions.onOpenSettings,
      );
    } else if (state.overlay == 'rules') {
      child = BigWalkerRulesModal(onClose: actions.onCloseOverlay);
    } else if (state.overlay == 'settings') {
      child = BigWalkerSettingsModal(onClose: actions.onCloseOverlay);
    }

    return AnimatedSwitcher(
      duration: BigWalkerTokens.modal,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      child: child,
    );
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
            opacity: asset == BigWalkerTokens.roomBgAsset ? 0.24 : 0.18,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _MissingSceneAssetFallback(assetPath: asset),
            ),
          ),
        ),
      ],
    );
  }
}

class _MissingSceneAssetFallback extends StatelessWidget {
  const _MissingSceneAssetFallback({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('[BigWalker] Missing scene asset: $assetPath');
      return true;
    }());

    if (kDebugMode) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              BigWalkerTokens.bgDeep.withOpacity(0.84),
              const Color(0xFF41251E).withOpacity(0.84),
            ],
          ),
          border: Border.all(color: BigWalkerTokens.accentAmber.withOpacity(0.65), width: 1.4),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image_rounded, color: BigWalkerTokens.accentAmber, size: 34),
                const SizedBox(height: 8),
                const Text(
                  'Missing Big Walker asset',
                  style: TextStyle(
                    color: BigWalkerTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assetPath,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: BigWalkerTokens.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1528), Color(0xFF060C18)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded, color: Color(0x889AB5D6), size: 20),
      ),
    );
  }
}
