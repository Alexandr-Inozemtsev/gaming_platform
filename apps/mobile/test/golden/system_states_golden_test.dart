// Назначение файла: зафиксировать golden-сценарии для системных UI-состояний в landscape viewport.
// Роль в проекте: визуальная регрессия reusable-компонентов loading/error/empty/reconnect для мобильного альбомного режима.
// Основные функции: рендер в 932x430 и 960x540 и сравнение с golden-эталонами.
// Связи с другими файлами: использует shared/ui/system_states.dart и AppTheme из theme/tokens.dart.
// Важно при изменении: golden-файлы обновлять осознанно через flutter test --update-goldens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletopplatform_mobile/shared/ui/system_states.dart';
import 'package:tabletopplatform_mobile/theme/tokens.dart';

Future<void> _pumpLandscape(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(MaterialApp(theme: AppTheme.build(), home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('golden: system states in 932x430', (tester) async {
    await _pumpLandscape(
      tester,
      const Size(932, 430),
      const Column(
        children: [
          ReconnectBanner(visible: true, text: 'reconnect'),
          Expanded(child: EmptyState(title: 'Пусто', subtitle: 'subtitle'))
        ]
      )
    );

    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/system_states_932x430.png'));
  }, skip: 'Запускать в UI пайплайне с --update-goldens.');

  testWidgets('golden: system states in 960x540', (tester) async {
    await _pumpLandscape(
      tester,
      const Size(960, 540),
      const Column(
        children: [
          ReconnectBanner(visible: true, text: 'reconnect'),
          Expanded(child: LoadingState(label: 'loading'))
        ]
      )
    );

    await expectLater(find.byType(Scaffold), matchesGoldenFile('goldens/system_states_960x540.png'));
  }, skip: 'Запускать в UI пайплайне с --update-goldens.');
}
