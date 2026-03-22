import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletopplatform_mobile/features/gameplay/big_walker/big_walker_match_state.dart';
import 'package:tabletopplatform_mobile/features/gameplay/big_walker/game_room_scene.dart';
import 'package:tabletopplatform_mobile/theme/game/big_walker_tokens.dart';

BigWalkerViewModel _buildViewModel({
  bool isStarted = true,
  bool isRollingDice = false,
  int? winnerIndex,
  String overlay = '',
  bool turnTransitionVisible = false,
  int? transitionPlayerIndex,
  int? activePathIndex,
  List<int> walkerPositions = const [0, 3, 5, 7],
  int currentPlayerIndex = 1,
  int diceValue = 4,
}) {
  const noop = _NoopActions();
  return BigWalkerViewModel(
    state: BigWalkerMatchViewState(
      title: 'Big Walker',
      participantsCount: 4,
      walkerPositions: walkerPositions,
      currentPlayerIndex: currentPlayerIndex,
      diceValue: diceValue,
      isRollingDice: isRollingDice,
      turnNumber: 3,
      activePathIndex: activePathIndex ?? (isRollingDice ? 4 : null),
      winnerIndex: winnerIndex,
      isStarted: isStarted,
      overlay: overlay,
      turnTransitionVisible: turnTransitionVisible,
      transitionPlayerIndex: transitionPlayerIndex,
      settlingPlayerIndex: null,
      pawnSettleTick: 0,
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


Offset _pawnOffset(WidgetTester tester, int playerIndex) {
  final pawnPosition = tester.widget<Positioned>(find.byKey(ValueKey('pawn-position-$playerIndex')));
  return Offset(pawnPosition.left!, pawnPosition.top!);
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


  testWidgets('dice roll + token movement animates from previous route position', (tester) async {
    await _pumpScene(tester, _buildViewModel(isRollingDice: true, walkerPositions: const [0, 3, 5, 7]));
    final start = _pawnOffset(tester, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameRoomScene(
            viewModel: _buildViewModel(
              isRollingDice: true,
              walkerPositions: const [4, 3, 5, 7],
              activePathIndex: 4,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 140));
    final mid = _pawnOffset(tester, 0);

    await tester.pumpAndSettle();
    final end = _pawnOffset(tester, 0);

    expect((mid - start).distance, greaterThan(0.5));
    expect((end - mid).distance, greaterThan(0.5));
    expect((mid - start).distance, lessThan((end - start).distance));
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

  testWidgets('active player emphasis is visible in chips and action context', (tester) async {
    await _pumpScene(tester, _buildViewModel());

    expect(find.text('Игрок 2 · ХОД'), findsOneWidget);
    expect(find.text('Ход игрока 2 · Раунд 3'), findsOneWidget);
  });

  testWidgets('overlay surfaces use shared modal system tokens', (tester) async {
    await _pumpScene(tester, _buildViewModel(overlay: 'pause'));

    final shellFinder = find.byWidgetPredicate((widget) {
      if (widget is! Container || widget.decoration is! BoxDecoration) return false;
      final decoration = widget.decoration! as BoxDecoration;
      return decoration.borderRadius == BorderRadius.circular(BigWalkerTokens.modalRadius);
    });
    expect(shellFinder, findsOneWidget);
    final shell = tester.widget<Container>(shellFinder.first);
    final decoration = shell.decoration as BoxDecoration;
    expect(decoration.border?.top.color, BigWalkerTokens.panelBorderStrong);
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
