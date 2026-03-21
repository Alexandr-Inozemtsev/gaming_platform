import 'package:flutter/material.dart';

import '../../../games/big_walker/big_walker_board.dart';
import '../../../theme/game/big_walker_tokens.dart';
import 'big_walker_match_state.dart';
import 'widgets/big_walker_action_panel.dart';
import 'widgets/big_walker_atmosphere.dart';
import 'widgets/big_walker_hud.dart';
import 'widgets/big_walker_player_chips.dart';

class GameRoomScene extends StatelessWidget {
  const GameRoomScene({
    super.key,
    required this.viewModel,
  });

  final BigWalkerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final state = viewModel.state;
    final actions = viewModel.actions;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [BigWalkerTokens.bgDeep, BigWalkerTokens.bgMid],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: _SceneImageLayer(),
          ),
          const Positioned.fill(child: BigWalkerAtmosphere()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(BigWalkerTokens.scenePadding),
              child: Column(
                children: [
                  BigWalkerHud(
                    participantsCount: state.participantsCount,
                    onParticipantsCountChanged: actions.onParticipantsCountChanged,
                    onToggleVideo: actions.onToggleVideo,
                    onToggleMic: actions.onToggleMic,
                    onQuickChat: actions.onQuickChat,
                  ),
                  const SizedBox(height: 10),
                  BigWalkerPlayerChips(
                    participantsCount: state.participantsCount,
                    currentPlayerIndex: state.currentPlayerIndex,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 0.96,
                        heightFactor: BigWalkerTokens.tableHeightFactor,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(BigWalkerTokens.tableRadius),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF1A243E), Color(0xFF131D34), Color(0xFF0E1629)],
                            ),
                            border: Border.all(color: BigWalkerTokens.cardBorder),
                            boxShadow: [
                              BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.18), blurRadius: 30),
                              BoxShadow(color: BigWalkerTokens.accentAmber.withOpacity(0.12), blurRadius: 36),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: RepaintBoundary(
                              child: BigWalkerBoard(
                                participantsCount: state.participantsCount,
                                walkerPositions: state.walkerPositions,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BigWalkerActionPanel(
                    isRollingDice: state.isRollingDice,
                    diceValue: state.diceValue,
                    onRollDice: actions.onRollDice,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneImageLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ...BigWalkerTokens.backgroundLayers.map(
          (asset) => Opacity(
            opacity: 0.2,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.6),
              radius: 1,
              colors: [
                BigWalkerTokens.accentCyan.withOpacity(0.16),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
