import 'package:flutter/material.dart';

import '../../../games/big_walker/big_walker_board.dart';
import '../../../theme/game/big_walker_tokens.dart';
import 'animations/big_walker_motion.dart';
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
          Positioned.fill(child: _SceneImageLayer()),
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
                    currentPlayerIndex: state.currentPlayerIndex,
                    turnNumber: state.turnNumber,
                    diceValue: state.diceValue,
                    onOpenPause: actions.onOpenPause,
                  ),
                  const SizedBox(height: 10),
                  BigWalkerPlayerChips(
                    participantsCount: state.participantsCount,
                    currentPlayerIndex: state.currentPlayerIndex,
                  ),
                  const SizedBox(height: 10),
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
                                activePathIndex: state.activePathIndex,
                                currentPlayerIndex: state.currentPlayerIndex,
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
                    isStarted: state.isStarted,
                    onStartMatch: actions.onStartMatch,
                    hasWinner: state.winnerIndex != null,
                  ),
                ],
              ),
            ),
          ),
          if (state.turnTransitionVisible && state.transitionPlayerIndex != null)
            _TurnTransitionBanner(player: state.transitionPlayerIndex!),
          _buildOverlay(state, actions),
        ],
      ),
    );
  }

  Widget _buildOverlay(BigWalkerMatchViewState state, BigWalkerMatchActions actions) {
    if (!state.isStarted && state.winnerIndex == null) {
      return _CenterSceneModal(
        title: 'Подготовка матча',
        subtitle: 'Выберите число участников и нажмите «Начать матч».',
        cta: 'Начать матч',
        onTap: actions.onStartMatch,
      );
    }

    if (state.winnerIndex != null) {
      return _CenterSceneModal(
        title: 'Победа игрока ${state.winnerIndex! + 1}',
        subtitle: 'Финиш достигнут за ${state.turnNumber} ходов.',
        cta: 'Новая партия',
        onTap: actions.onStartMatch,
        winner: true,
      );
    }

    if (state.overlay == 'pause') {
      return _CenterSceneModal(
        title: 'Пауза',
        subtitle: 'Поставьте игру на паузу или откройте правила/настройки.',
        cta: 'Продолжить',
        onTap: actions.onCloseOverlay,
        secondaryActions: [
          _SecondaryAction(label: 'Правила', onTap: actions.onOpenRules),
          _SecondaryAction(label: 'Настройки', onTap: actions.onOpenSettings),
        ],
      );
    }

    if (state.overlay == 'rules') {
      return _CenterSceneModal(
        title: 'Правила',
        subtitle:
            '1) Бросайте кубик по очереди.\n2) Фишка движется на выпавшее число клеток.\n3) Кто первым дойдет до финиша — побеждает.',
        cta: 'Понятно',
        onTap: actions.onCloseOverlay,
      );
    }

    if (state.overlay == 'settings') {
      return _CenterSceneModal(
        title: 'Настройки',
        subtitle: 'В этой демо-версии доступны базовые настройки комнаты и интерфейса.',
        cta: 'Закрыть',
        onTap: actions.onCloseOverlay,
      );
    }

    return const SizedBox.shrink();
  }
}

class _TurnTransitionBanner extends StatelessWidget {
  const _TurnTransitionBanner({required this.player});
  final int player;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 98,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: BigWalkerMotion.turnGlow,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: BigWalkerTokens.accentCyan.withOpacity(0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: BigWalkerTokens.accentCyan),
            boxShadow: [BoxShadow(color: BigWalkerTokens.accentCyan.withOpacity(0.3), blurRadius: 18)],
          ),
          child: Text('Ход переходит к игроку ${player + 1}', style: const TextStyle(color: BigWalkerTokens.textPrimary, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _CenterSceneModal extends StatelessWidget {
  const _CenterSceneModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
    this.winner = false,
    this.secondaryActions = const [],
  });

  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;
  final bool winner;
  final List<_SecondaryAction> secondaryActions;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: AnimatedScale(
            duration: BigWalkerMotion.winnerModal,
            curve: BigWalkerMotion.winnerModalCurve,
            scale: 1,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: BigWalkerTokens.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: winner ? BigWalkerTokens.accentAmber : BigWalkerTokens.cardBorder),
                boxShadow: [
                  BoxShadow(color: (winner ? BigWalkerTokens.accentAmber : BigWalkerTokens.accentCyan).withOpacity(0.28), blurRadius: 24),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(color: BigWalkerTokens.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: BigWalkerTokens.textSecondary)),
                  if (secondaryActions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: secondaryActions
                          .map((action) => GestureDetector(
                                onTap: action.onTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: BigWalkerTokens.bgSoft,
                                    border: Border.all(color: BigWalkerTokens.cardBorder),
                                  ),
                                  child: Text(action.label, style: const TextStyle(color: BigWalkerTokens.textPrimary, fontSize: 12)),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: double.infinity,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(colors: [BigWalkerTokens.accentAmber, BigWalkerTokens.accentAmber.withOpacity(0.82)]),
                      ),
                      child: Text(cta, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction {
  const _SecondaryAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
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
