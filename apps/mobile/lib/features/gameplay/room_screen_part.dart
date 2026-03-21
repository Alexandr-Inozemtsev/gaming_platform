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
    final viewState = s.bigWalkerViewState;
    final actions = s.bigWalkerActions;

    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1F36), Color(0xFF0F1324)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                BigWalkerRoomHeader(
                  title: viewState.title,
                  participantsCount: viewState.participantsCount,
                  onParticipantsCountChanged: actions.onParticipantsCountChanged,
                ),
                BigWalkerPlayerStrip(
                  participantsCount: viewState.participantsCount,
                  currentPlayerIndex: viewState.currentPlayerIndex,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: BigWalkerBoard(
                    participantsCount: viewState.participantsCount,
                    walkerPositions: viewState.walkerPositions,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                BigWalkerHud(
                  isRollingDice: viewState.isRollingDice,
                  diceValue: viewState.diceValue,
                  onRollDice: actions.onRollDice,
                  onToggleVideo: actions.onToggleVideo,
                  onToggleMic: actions.onToggleMic,
                  onQuickChat: actions.onQuickChat,
                ),
              ],
            ),
          ),
        ),
      ),
      if (s.videoOverlayVisible) VideoOverlayWidget(state: s),
    ]);
  }
}

class VideoOverlayWidget extends StatelessWidget {
  const VideoOverlayWidget({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final warning = state.rtcConfigWarning;
    return Positioned.fill(
      child: Container(
        color: AppTokens.videoOverlayBg,
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(state.t('video.title')),
                if (warning.isNotEmpty)
                  Text(
                    warning,
                    style: const TextStyle(color: AppTokens.editorWarning)
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.videoParticipants.take(4).map((id) {
                    return Container(
                      width: 120,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTokens.card.withOpacity(0.9),
                        border: Border.all(color: AppColors.videoBorder),
                        borderRadius: BorderRadius.circular(AppTokens.videoTileRadius)
                      ),
                      child: Text(id == state.userId ? 'Local Video' : 'Remote: $id')
                    );
                  }).toList()
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  OutlinedButton(
                    onPressed: state.mediaPermissionGranted
                        ? state.toggleCamera
                        : () {
                            state.grantMediaPermission();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.t('video.permissionGranted')))
                            );
                          },
                    child: Text(state.cameraEnabled ? state.t('video.cameraOn') : state.t('video.cameraOff'))
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: state.mediaPermissionGranted
                        ? state.toggleMic
                        : () {
                            state.grantMediaPermission();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.t('video.permissionGranted')))
                            );
                          },
                    child: Text(state.micEnabled ? state.t('video.micOn') : state.t('video.micOff'))
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () => state.muteAllVideo(), child: const Text('Отключить всем')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: state.hangupVideo, child: Text(state.t('video.hangup')))
                ]),
                Text('${state.t('room.videoStatus')}: ${state.videoStatus}')
              ])
            )
          )
        )
      )
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
