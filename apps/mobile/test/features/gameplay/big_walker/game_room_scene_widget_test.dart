import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletopplatform_mobile/features/gameplay/big_walker/big_walker_match_state.dart';
import 'package:tabletopplatform_mobile/features/gameplay/big_walker/game_room_scene.dart';

BigWalkerViewModel _buildViewModel({
  bool isStarted = true,
  bool isRollingDice = false,
  int? winnerIndex,
  String overlay = '',
  bool turnTransitionVisible = false,
  int? transitionPlayerIndex,
}) {
  const noop = _NoopActions();
  return BigWalkerViewModel(
    state: BigWalkerMatchViewState(
      title: 'Big Walker',
      participantsCount: 4,
      walkerPositions: const [0, 3, 5, 7],
      currentPlayerIndex: 1,
      diceValue: 4,
      isRollingDice: isRollingDice,
      turnNumber: 3,
      activePathIndex: isRollingDice ? 4 : null,
      winnerIndex: winnerIndex,
      isStarted: isStarted,
      overlay: overlay,
      turnTransitionVisible: turnTransitionVisible,
      transitionPlayerIndex: transitionPlayerIndex,
    ),
    actions: noop.actions,
  );
}

Future<void> _pumpScene(WidgetTester tester, BigWalkerViewModel viewModel) async {
  tester.view.physicalSize = const Size(932, 430);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(MaterialApp(home: Scaffold(body: GameRoomScene(viewModel: viewModel))));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('idle state shows player select and start CTA', (tester) async {
    await _pumpScene(tester, _buildViewModel(isStarted: false));

    expect(find.text('Подготовка партии'), findsOneWidget);
    expect(find.text('Начать матч'), findsWidgets);
  });

  testWidgets('dice roll state shows animated roll status', (tester) async {
    await _pumpScene(tester, _buildViewModel(isRollingDice: true));

    expect(find.text('Кубик вращается...'), findsOneWidget);
    expect(find.text('D20 CORE'), findsOneWidget);
  });

  testWidgets('next turn overlay is visible', (tester) async {
    await _pumpScene(tester, _buildViewModel(turnTransitionVisible: true, transitionPlayerIndex: 2));

    expect(find.text('Ход игрока 3'), findsOneWidget);
  });

  testWidgets('pause and nested overlays open expected modals', (tester) async {
    await _pumpScene(tester, _buildViewModel(overlay: 'pause'));
    expect(find.text('Пауза'), findsOneWidget);

    await _pumpScene(tester, _buildViewModel(overlay: 'rules'));
    expect(find.text('Правила Big Walker'), findsOneWidget);

    await _pumpScene(tester, _buildViewModel(overlay: 'settings'));
    expect(find.text('Настройки стола'), findsOneWidget);
  });

  testWidgets('victory state shows winner modal', (tester) async {
    await _pumpScene(tester, _buildViewModel(winnerIndex: 0));

    expect(find.text('Победа игрока 1'), findsOneWidget);
    expect(find.text('Новая партия'), findsWidgets);
  });

  testWidgets('binary-free room background is rendered without asset diagnostics', (tester) async {
    await _pumpScene(tester, _buildViewModel());

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('Missing Big Walker asset'), findsNothing);
    expect(find.byIcon(Icons.broken_image_rounded), findsNothing);
  });

  testWidgets('all target states render in binary-free mode', (tester) async {
    final cases = <({String name, BigWalkerViewModel model, String expectedLabel})>[
      (name: 'idle', model: _buildViewModel(isStarted: false), expectedLabel: 'Подготовка партии'),
      (name: 'dice_roll', model: _buildViewModel(isRollingDice: true), expectedLabel: 'Кубик вращается...'),
      (
        name: 'next_turn',
        model: _buildViewModel(turnTransitionVisible: true, transitionPlayerIndex: 2),
        expectedLabel: 'Ход игрока 3',
      ),
      (name: 'pause', model: _buildViewModel(overlay: 'pause'), expectedLabel: 'Пауза'),
      (name: 'rules', model: _buildViewModel(overlay: 'rules'), expectedLabel: 'Правила Big Walker'),
      (name: 'settings', model: _buildViewModel(overlay: 'settings'), expectedLabel: 'Настройки стола'),
      (name: 'victory', model: _buildViewModel(winnerIndex: 0), expectedLabel: 'Победа игрока 1'),
    ];

    for (final scenario in cases) {
      await _pumpScene(tester, scenario.model);
      expect(find.text(scenario.expectedLabel), findsOneWidget, reason: 'state=${scenario.name}');
    }
  });
}

class _NoopActions {
  const _NoopActions();

  BigWalkerMatchActions get actions => BigWalkerMatchActions(
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
      );
}
