// Назначение файла: зафиксировать golden-сценарии для основных landscape viewport классов из продуктового ТЗ.
// Роль в проекте: ранняя защита от regressions компоновки UI-kit/HUD на разных соотношениях сторон.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletopplatform_mobile/shared/ui/ui_kit.dart';
import 'package:tabletopplatform_mobile/theme/tokens.dart';

Future<void> _pumpViewport(WidgetTester tester, Size logicalSize, Widget child) async {
  tester.view.physicalSize = logicalSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(MaterialApp(theme: AppTheme.build(), home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

Widget _fixture() {
  return Padding(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Column(
      children: [
        const TopBar(title: 'Viewport Golden Fixture', trailing: InviteCodeBadge(code: 'ABCD-1234')),
        const SizedBox(height: AppSpacing.sm),
        const FeaturedGameBanner(title: 'Tile Placement', subtitle: 'Landscape-first layout quality gate'),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          children: [
            Expanded(child: PlayerSlot(name: 'Player 1', ready: true, host: true)),
            SizedBox(width: AppSpacing.xs),
            Expanded(child: PlayerSlot(name: 'Player 2', ready: false)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const ScorePanel(items: {'You': 28, 'Opp': 24}),
        const SizedBox(height: AppSpacing.sm),
        ActionBar(actions: [
          AppButton(label: 'Move', onPressed: () {}),
          const AppButton(label: 'Rules', variant: AppButtonVariant.secondary),
          const AppButton(label: 'Pass', variant: AppButtonVariant.ghost),
        ]),
        const SizedBox(height: AppSpacing.sm),
        HandTray(items: const ['A1', 'B2', 'C3', 'D4', 'E5'], selectedIndex: 1, onSelect: (_) {}),
      ],
    ),
  );
}

void main() {
  const viewports = <({String name, Size size})>[
    (name: '812x375', size: Size(812, 375)),
    (name: '844x390', size: Size(844, 390)),
    (name: '896x414', size: Size(896, 414)),
    (name: '932x430', size: Size(932, 430)),
    (name: '960x540', size: Size(960, 540)),
    (name: '1024x600', size: Size(1024, 600)),
    (name: '1180x820', size: Size(1180, 820)),
  ];

  for (final viewport in viewports) {
    testWidgets('golden: ui kit fixture ${viewport.name}', (tester) async {
      await _pumpViewport(tester, viewport.size, _fixture());
      await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/ui_kit_${viewport.name}.png'));
    }, skip: 'Запускать в UI пайплайне с --update-goldens.');
  }
}
