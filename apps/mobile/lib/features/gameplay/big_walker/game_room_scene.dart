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
          const Positioned.fill(child: _ProceduralRoomLayer()),
          const Positioned.fill(child: _SceneEnhancementImageLayer()),
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

class _ProceduralRoomLayer extends StatelessWidget {
  const _ProceduralRoomLayer();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: const [
          DecoratedBox(
            decoration: BoxDecoration(gradient: BigWalkerTokens.roomAtmosphereGradient),
          ),
          DecoratedBox(
            decoration: BoxDecoration(gradient: BigWalkerTokens.roomWarmSpotGradient),
          ),
          DecoratedBox(
            decoration: BoxDecoration(gradient: BigWalkerTokens.roomCeilingGlowGradient),
          ),
          _SceneParticles(),
        ],
      ),
    );
  }
}

class _SceneParticles extends StatelessWidget {
  const _SceneParticles();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SceneParticlesPainter(),
      isComplex: true,
      willChange: false,
    );
  }
}

class _SceneParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dustPaint = Paint()..style = PaintingStyle.fill;
    const particles = <({double x, double y, double r, double opacity})>[
      (x: 0.08, y: 0.19, r: 36, opacity: 0.08),
      (x: 0.19, y: 0.27, r: 22, opacity: 0.09),
      (x: 0.32, y: 0.16, r: 26, opacity: 0.07),
      (x: 0.45, y: 0.24, r: 28, opacity: 0.08),
      (x: 0.58, y: 0.2, r: 30, opacity: 0.07),
      (x: 0.67, y: 0.3, r: 24, opacity: 0.09),
      (x: 0.8, y: 0.22, r: 32, opacity: 0.08),
      (x: 0.9, y: 0.17, r: 20, opacity: 0.1),
      (x: 0.12, y: 0.62, r: 42, opacity: 0.05),
      (x: 0.31, y: 0.56, r: 38, opacity: 0.04),
      (x: 0.53, y: 0.64, r: 44, opacity: 0.05),
      (x: 0.74, y: 0.58, r: 34, opacity: 0.04),
      (x: 0.88, y: 0.68, r: 40, opacity: 0.05),
    ];

    for (final particle in particles) {
      dustPaint.color = BigWalkerTokens.accentCyan.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(size.width * particle.x, size.height * particle.y), particle.r, dustPaint);
    }

    final horizonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x441C324E), Colors.transparent],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, horizonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SceneEnhancementImageLayer extends StatelessWidget {
  const _SceneEnhancementImageLayer();

  @override
  Widget build(BuildContext context) {
    if (BigWalkerTokens.backgroundEnhancementLayers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ...BigWalkerTokens.backgroundEnhancementLayers.map(
          (asset) => IgnorePointer(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
