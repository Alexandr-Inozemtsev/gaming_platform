# План и результат переработки UI под mobile landscape

## Этап 1. Анализ (перед изменениями)
- Точка входа UI: `apps/mobile/lib/main.dart`.
- Токены: `apps/mobile/lib/theme/tokens.dart`.
- Основная проблема: монолитная разметка и слабая адаптация room/gameplay для маленькой высоты экрана (landscape mobile), что вызывало `RenderFlex overflow`.
- Дополнительно: глобальные `AppBar`/`NavigationBar` отнимали полезную высоту в room.

## Референс mockups
В данном окружении путь `C:\Personal\boardgames-react-mockups` недоступен, поэтому переработка выполнена по текущим UX-требованиям и существующей архитектуре приложения с упором на:
- landscape-first,
- production-ready поведение,
- устранение переполнений и блокеров gameplay.

## Что сделано
1. Включена строгая ориентация только в landscape (`left`/`right`) на уровне `main()`.
2. Переработан `MainShell`:
   - в режиме room убираются глобальные `AppBar` и нижняя навигация для увеличения игровой области.
3. Переработан `RoomScreen`:
   - добавлен адаптивный режим `compact` по высоте;
   - в compact скрывается вторичный блок chat/log и приоритет отдаётся игровому полю;
   - добавлена явная кнопка возврата в Home прямо в комнате.
4. Переработан `TileBoardWidget`:
   - добавлена адаптация для очень маленькой высоты (скрытие верхней панели drag/switch), чтобы избежать overflow и сохранить играбельность.

## Где лежат ключевые части
- Токены: `apps/mobile/lib/theme/tokens.dart`
- Основной shell + экраны: `apps/mobile/lib/main.dart`

## Как подключать реальные данные
- `AppState` уже использует `ApiClient`/`WsClient`.
- Для перехода с mock/offline на online необходимо обеспечить доступность backend (API/Realtime), после чего UI уже работает с реальными ответами сервисов.

## Следующие шаги
1. Вынести `RoomScreen`, `GameplayHUD`, `TileBoardWidget`, `RollWriteBoardWidget` в `shared/ui` и `features/gameplay/ui` для полноценной модульной структуры.
2. Добавить отдельные reusable-компоненты состояний (`LoadingState`, `ErrorState`, `EmptyState`, `ReconnectBanner`) как отдельные файлы и покрыть их виджет-тестами.
3. Ввести preview-экран системных состояний и визуальные golden-тесты для landscape viewport (932x430, 960x540).
