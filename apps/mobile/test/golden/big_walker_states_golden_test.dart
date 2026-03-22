import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletopplatform_mobile/features/gameplay/big_walker/big_walker_match_state.dart';
import 'package:tabletopplatform_mobile/features/gameplay/big_walker/game_room_scene.dart';

Future<void> _pumpState(
  WidgetTester tester, {
  required String name,
  bool isStarted = true,
  bool isRollingDice = false,
  int? winnerIndex,
  String overlay = '',
  bool turnTransitionVisible = false,
  int? transitionPlayerIndex,
}) async {
  tester.view.physicalSize = const Size(960, 540);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final viewModel = BigWalkerViewModel(
    state: BigWalkerMatchViewState(
      title: 'Big Walker',
      participantsCount: 4,
      walkerPositions: const [0, 10, 17, 24],
      currentPlayerIndex: 1,
      diceValue: 5,
      isRollingDice: isRollingDice,
      turnNumber: 6,
      activePathIndex: isRollingDice ? 12 : null,
      winnerIndex: winnerIndex,
      isStarted: isStarted,
      overlay: overlay,
      turnTransitionVisible: turnTransitionVisible,
      transitionPlayerIndex: transitionPlayerIndex,
    ),
    actions: BigWalkerMatchActions(
      onParticipantsCountChanged: (_) {},
      onRollDice: () {},
      onToggleVideo: () {},
      onToggleMic: () {},
      onQuickChat: () {},
      onStartMatch: () {},
      onOpenPause: () {},
      onOpenRules: () {},
      onOpenSettings: () {},
      onCloseOverlay: () {},
    ),
  );

  await tester.pumpWidget(MaterialApp(home: Scaffold(body: GameRoomScene(viewModel: viewModel))));
  await tester.pumpAndSettle();

  await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/big_walker_$name.png'));
}

void main() {
  testWidgets('golden: big walker idle', (tester) async {
    await _pumpState(tester, name: 'idle', isStarted: false);
  });

  testWidgets('golden: big walker dice roll', (tester) async {
    await _pumpState(tester, name: 'dice_roll', isRollingDice: true);
  });

  testWidgets('golden: big walker next turn overlay', (tester) async {
    await _pumpState(tester, name: 'next_turn', turnTransitionVisible: true, transitionPlayerIndex: 2);
  });

  testWidgets('golden: big walker pause', (tester) async {
    await _pumpState(tester, name: 'pause', overlay: 'pause');
  });

  testWidgets('golden: big walker rules', (tester) async {
    await _pumpState(tester, name: 'rules', overlay: 'rules');
  });

  testWidgets('golden: big walker settings', (tester) async {
    await _pumpState(tester, name: 'settings', overlay: 'settings');
  });

  testWidgets('golden: big walker victory', (tester) async {
    await _pumpState(tester, name: 'victory', winnerIndex: 0);
  });
}
