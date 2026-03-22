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
   - добавлен `ReconnectBanner` в верхней части shell для offline/reconnect состояния.
3. Переработан `RoomScreen`:
   - добавлен адаптивный режим `compact` по высоте;
   - в compact скрывается вторичный блок chat/log и приоритет отдаётся игровому полю;
   - добавлена явная кнопка возврата в Home прямо в комнате.
4. Переработан `TileBoardWidget`:
   - добавлена адаптация для очень маленькой высоты (скрытие верхней панели drag/switch), чтобы избежать overflow и сохранить играбельность.
5. Начата декомпозиция монолита:
   - room/gameplay вынесены в отдельный feature part-файл.
6. Добавлены reusable state-компоненты:
   - `LoadingState`, `ErrorState`, `EmptyState`, `ReconnectBanner`.
7. Добавлены golden-тесты под viewport 932x430 и 960x540 (подготовлены и помечены для запуска в UI-пайплайне).

## Где лежат ключевые части
- Токены: `apps/mobile/lib/theme/tokens.dart`
- Основной shell + экраны: `apps/mobile/lib/main.dart`
- Feature room/gameplay: `apps/mobile/lib/features/gameplay/room_screen_part.dart`
- Reusable системные состояния: `apps/mobile/lib/shared/ui/system_states.dart`
- Golden-тесты: `apps/mobile/test/golden/system_states_golden_test.dart`

## Как подключать реальные данные
- `AppState` уже использует `ApiClient`/`WsClient`.
- Для перехода с mock/offline на online необходимо обеспечить доступность backend (API/Realtime), после чего UI уже работает с реальными ответами сервисов.

## Следующие шаги
1. Вынести `RoomScreen`, `GameplayHUD`, `TileBoardWidget`, `RollWriteBoardWidget` в `shared/ui` и `features/gameplay/ui` для полноценной модульной структуры.
2. Добавить отдельные reusable-компоненты состояний (`LoadingState`, `ErrorState`, `EmptyState`, `ReconnectBanner`) как отдельные файлы и покрыть их виджет-тестами.
3. Ввести preview-экран системных состояний и визуальные golden-тесты для landscape viewport (932x430, 960x540).

## Big Walker visual parity achieved

Целевой уровень для Big Walker считается достигнутым, когда одновременно выполнены следующие критерии:

1. **Диагностируемость ассетов**
   - В debug отсутствующий слой сцены не «исчезает тихо»: на экране появляется явный индикатор missing asset с путем к файлу.
   - В release вместо debug-индикатора используется аккуратный визуальный fallback, который не ломает композицию сцены.

2. **Композиция handoff-уровня (reference vs реализация)**
   - На ключевых состояниях (`idle`, `dice roll`, `next turn`, `pause`, `rules`, `settings`, `victory`) сохраняется многослойная сцена: фон комнаты + атмосфера + стол/борд + HUD + action panel + overlay/modal.
   - Активный ход остаётся визуально очевидным (HUD + chips + transition overlay), а кнопка действия и dice-блок читаемы на всех целевых landscape viewport.
   - Контраст текста/контейнеров достаточный для чтения без потери деталей фона.

3. **Placeholders только как controlled fallback**
   - Runtime-резолвер ассетов больше не опирается на placeholder как основную стратегию.
   - Placeholder допускается только как управляемый fallback для известных ключей при отсутствии финального ассета.

4. **Защита от визуальных регрессий**
   - Добавлены widget-тесты и golden-тесты под Big Walker для ключевых состояний.
   - Изменения UI считаются завершёнными только при прохождении тестов и актуализации golden-эталонов.
