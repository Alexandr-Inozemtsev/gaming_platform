// Назначение файла: вынести gameplay/room UI из монолитного main.dart в feature-часть.
// Роль в проекте: содержать контейнер комнаты, игровые доски и HUD-элементы для landscape mobile.
// Основные функции: RoomScreen, VideoOverlayWidget, TileBoardWidget, RollWriteBoardWidget.
// Связи с другими файлами: является part-файлом для main.dart и использует AppState/AppTokens/локализованные строки.
// Важно при изменении: поддерживать compact-layout и не допускать overflow на mobile-landscape высотах.

part of '../../main.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.state});
  final AppState state;
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    if (s.currentGameId == 'big_walker_demo') {
      return _UnityBigWalkerRoom(state: s);
    }

    final vm = s.bigWalkerViewModel;

    return Stack(
      children: [
        GameRoomScene(viewModel: vm),
        AnimatedSwitcher(
          duration: BigWalkerMotion.turnGlow,
          switchInCurve: BigWalkerMotion.turnGlowCurve,
          switchOutCurve: BigWalkerMotion.turnGlowCurve,
          child: s.videoOverlayVisible ? VideoOverlayWidget(key: const ValueKey('video-overlay'), state: s) : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _UnityBigWalkerRoom extends StatelessWidget {
  const _UnityBigWalkerRoom({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: BigWalkerTokens.roomGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Большая Бродилка · Unity',
                      style: TextStyle(
                        color: BigWalkerTokens.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: state.returnToHomeFromUnityBigWalker,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('На главную'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: BigWalkerTokens.panelBorder),
                    gradient: BigWalkerTokens.panelGradient,
                    boxShadow: BigWalkerTokens.panelShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: state.unityBigWalkerRunning
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unity runtime активен',
                                style: TextStyle(
                                  color: BigWalkerTokens.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Старая Flutter-реализация отключена. Комната использует Unity-модуль Big Walker.',
                                style: TextStyle(
                                  color: BigWalkerTokens.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                height: 220,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: BigWalkerTokens.panelBorder.withOpacity(0.9)),
                                  color: const Color(0xFF0A1625),
                                ),
                                child: const Text(
                                  'Unity Big Walker Scene',
                                  style: TextStyle(
                                    color: BigWalkerTokens.accentCyan,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  onPressed: state.returnToHomeFromUnityBigWalker,
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Вернуться на главную страницу'),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: FilledButton.icon(
                              onPressed: state.launchUnityBigWalker,
                              icon: const Icon(Icons.play_circle_fill_rounded),
                              label: const Text('Запустить игру на платформе'),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoOverlayWidget extends StatelessWidget {
  const VideoOverlayWidget({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final warning = state.rtcConfigWarning;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < BigWalkerTokens.roomOverlayCompactHeight;
    final maxPanelHeight = compact ? screenHeight * 0.48 : screenHeight * 0.58;

    return Positioned.fill(
      child: Stack(
        children: [
          const IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: BigWalkerTokens.overlayBackdropGradient))),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                BigWalkerTokens.space12,
                compact ? BigWalkerTokens.space6 : BigWalkerTokens.space12,
                BigWalkerTokens.space12,
                BigWalkerTokens.space12,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: compact ? 900 : 960, maxHeight: maxPanelHeight),
                  child: BigWalkerRoomOverlayPanel(
                    compact: compact,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.t('video.title'),
                            style: TextStyle(
                              color: BigWalkerTokens.textPrimary,
                              fontSize: compact ? 14 : 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (warning.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              warning,
                              style: TextStyle(
                                color: AppTokens.editorWarning,
                                fontSize: compact ? 11 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          SizedBox(height: compact ? 8 : 10),
                          Wrap(
                            spacing: compact ? 6 : 8,
                            runSpacing: compact ? 6 : 8,
                            children: state.videoParticipants.take(4).map((id) {
                              return _VideoParticipantCard(id: id, state: state, compact: compact);
                            }).toList(),
                          ),
                          SizedBox(height: compact ? 8 : 10),
                          Wrap(
                            spacing: compact ? 6 : 8,
                            runSpacing: compact ? 6 : 8,
                            children: [
                              BigWalkerRoomOverlayButton(
                                label: state.cameraEnabled ? state.t('video.cameraOn') : state.t('video.cameraOff'),
                                icon: Icons.videocam_rounded,
                                primary: state.cameraEnabled,
                                compact: compact,
                                onTap: state.mediaPermissionGranted
                                    ? state.toggleCamera
                                    : () {
                                        state.grantMediaPermission();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(state.t('video.permissionGranted'))),
                                        );
                                      },
                              ),
                              BigWalkerRoomOverlayButton(
                                label: state.micEnabled ? state.t('video.micOn') : state.t('video.micOff'),
                                icon: Icons.mic_rounded,
                                primary: state.micEnabled,
                                compact: compact,
                                onTap: state.mediaPermissionGranted
                                    ? state.toggleMic
                                    : () {
                                        state.grantMediaPermission();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(state.t('video.permissionGranted'))),
                                        );
                                      },
                              ),
                              BigWalkerRoomOverlayButton(
                                label: 'Отключить всем',
                                icon: Icons.volume_off_rounded,
                                compact: compact,
                                onTap: state.muteAllVideo,
                              ),
                              BigWalkerRoomOverlayButton(
                                label: state.t('video.hangup'),
                                icon: Icons.call_end_rounded,
                                compact: compact,
                                danger: true,
                                onTap: state.hangupVideo,
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 6 : 8),
                          Text(
                            '${state.t('room.videoStatus')}: ${state.videoStatus}',
                            style: const TextStyle(
                              color: BigWalkerTokens.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

class _VideoParticipantCard extends StatelessWidget {
  const _VideoParticipantCard({required this.id, required this.state, required this.compact});
  final String id;
  final AppState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 106 : 122,
      height: compact ? 68 : 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: BigWalkerTokens.panelGradient,
        border: Border.all(color: BigWalkerTokens.panelBorder.withOpacity(0.95)),
        borderRadius: BorderRadius.circular(BigWalkerTokens.cardRadius),
        boxShadow: const [
          BoxShadow(color: Color(0x5A091223), blurRadius: 10, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x3E4BD3FF), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          id == state.userId ? 'Local Video' : 'Remote: $id',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: BigWalkerTokens.textPrimary,
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class TileBoardWidget extends StatelessWidget {
  const TileBoardWidget({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 220;
        return Column(children: [
          if (!compact)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Draggable<String>(
                data: state.selectedTile,
                feedback: Material(color: Colors.transparent, child: _tileCell(state.selectedTile, highlight: true)),
                child: _tileCell(state.selectedTile, highlight: true)
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: state.toggleTileSymbol, child: Text(state.t('room.switch')))
            ]),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: 16,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (_, i) {
                final r = i ~/ 4;
                final c = i % 4;
                final isPreview = state.previewRow == r && state.previewCol == c;
                return DragTarget<String>(
                  onWillAcceptWithDetails: (_) {
                    state.updatePreview(r, c);
                    return true;
                  },
                  onLeave: (_) => state.updatePreview(null, null),
                  onAcceptWithDetails: (_) {
                    state.updatePreview(null, null);
                    state.confirmTilePlacement(r, c);
                  },
                  builder: (_, __, ___) => GestureDetector(
                    onTap: () => state.confirmTilePlacement(r, c),
                    child: _tileCell(state.tileGrid[r][c], highlight: isPreview)
                  )
                );
              }
            )
          )
        ]);
      }
    );
  }

  Widget _tileCell(String? value, {required bool highlight}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: highlight ? state.activeBoardHighlight.withOpacity(0.25) : AppTokens.card,
        border: Border.all(color: AppTokens.boardGridLine),
        borderRadius: BorderRadius.circular(8)
      ),
      alignment: Alignment.center,
      child: Text(value ?? '', style: const TextStyle(fontSize: 18))
    );
  }
}

class RollWriteBoardWidget extends StatelessWidget {
  const RollWriteBoardWidget({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('${state.t('room.dice')}: [${state.dice[0]}][${state.dice[1]}]'),
      Expanded(
        child: GridView.builder(
          itemCount: 25,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemBuilder: (_, i) {
            final r = i ~/ 5;
            final c = i % 5;
            final canMark = state.rollSheet[r][c] == 0 && r + c + 2 == state.dice[0] + state.dice[1];
            return GestureDetector(
              onTap: () => state.markRollCell(r, c),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: canMark ? state.activeBoardHighlight.withOpacity(0.25) : AppTokens.card,
                  border: Border.all(color: AppTokens.boardGridLine),
                  borderRadius: BorderRadius.circular(6)
                ),
                alignment: Alignment.center,
                child: Text(state.rollSheet[r][c] == 1 ? 'X' : '')
              )
            );
          }
        )
      )
    ]);
  }
}
