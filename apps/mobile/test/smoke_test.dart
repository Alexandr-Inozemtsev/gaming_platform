// Назначение файла: предоставить минимальный e2e smoke-тест Flutter для ключевого пользовательского пути MVP.
// Роль в проекте: быстро проверять, что приложение отрисовывает shell и навигация Catalog -> Room доступна.
// Основные функции: запуск виджета MainShell с тестовым AppState и проверка переходов по нижней навигации.
// Связи с другими файлами: использует apps/mobile/lib/main.dart и ключевые экраны Catalog/Room.
// Важно при изменении: тест должен оставаться быстрым и стабильным, без зависимости от реального backend.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletopplatform_mobile/main.dart';

void main() {
  testWidgets('smoke: login -> open catalog -> open game room (минимальный shell путь)', (tester) async {
    final state = AppState();
    state.authorized = true;
    state.userId = 'u_test';
    state.games = const [
      {'id': 'tile_placement_demo', 'title': 'Tile Placement Demo'}
    ];

    await tester.pumpWidget(MaterialApp(home: MainShell(state: state)));
    await tester.pumpAndSettle();

    expect(find.text('Catalog'), findsOneWidget);

    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();

    expect(find.text('Join'), findsWidgets);

    await tester.tap(find.text('Room'));
    await tester.pumpAndSettle();

    expect(find.textContaining('tile_placement_demo'), findsWidgets);
  });
}
