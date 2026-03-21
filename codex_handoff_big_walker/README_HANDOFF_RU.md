# Handoff для Codex — Big Walker Demo

## Что внутри
Этот пакет содержит **референс-экраны** для первой демо-игры `big_walker_demo` внутри Flutter-клиента репозитория `Alexandr-Inozemtsev/gaming_platform`.

Это **не нарезанные production-ассеты**, а **визуальные эталоны** для Codex:
- композиция экрана;
- стиль;
- свет;
- палитра;
- расположение HUD, поля, модалок и action panel;
- состояние броска кубика, перехода хода, победы и правил.

## Важное ограничение
Codex не сможет автоматически превратить полноэкранные мокапы в готовый экран 1:1 без ручной декомпозиции.
Поэтому задача для Codex должна быть такой:
1. использовать эти изображения как **visual references**;
2. реализовать экран **кодом во Flutter**;
3. опираться на текущую механику `big_walker_demo`;
4. не использовать placeholder UI;
5. разложить экран на слои, токены и виджеты;
6. подключить полноэкранные референсы в `assets/design/big_walker_reference/` для разработки и сверки.

## Репозиторий и текущая база
В репозитории уже есть Flutter-клиент в `apps/mobile`, а точка входа — `apps/mobile/lib/main.dart`, где уже подключены:
- `theme/game/big_walker_tokens.dart`
- `games/big_walker/big_walker_board.dart`
- `features/gameplay/big_walker/game_room_scene.dart`
- `features/gameplay/big_walker/animations/big_walker_motion.dart`
- `features/gameplay/big_walker/big_walker_match_state.dart`

В `main.dart` уже есть:
- landscape-only запуск;
- `big_walker_demo`;
- механика игроков 2–6;
- бросок кубика;
- пошаговое движение по клеткам;
- победа при достижении последней клетки.

## Что сделать Codex
### 1. Сохранить механику
Не переписывать игровые правила.
Использовать существующую механику из `AppState.rollDiceAndMoveWalker()` и существующую интеграцию `GameRoomScene`.

### 2. Подключить reference-экраны
Скопировать изображения из этого пакета в:
`apps/mobile/assets/design/big_walker_reference/`

Добавить их в `apps/mobile/pubspec.yaml`.

### 3. Использовать референсы как источники визуала
Реализовать кодом:
- тёмную волшебную комнату;
- premium fantasy table;
- красивый board frame;
- читаемый маршрут;
- крупный roll button;
- top HUD с текущим игроком, порядком игроков, turn/round;
- pause / rules / settings / victory modal в одном стиле.

### 4. Пересобрать Big Walker UI
Целевые файлы:
- `apps/mobile/lib/theme/game/big_walker_tokens.dart`
- `apps/mobile/lib/games/big_walker/big_walker_board.dart`
- `apps/mobile/lib/features/gameplay/big_walker/game_room_scene.dart`
- `apps/mobile/lib/features/gameplay/big_walker/widgets/big_walker_action_panel.dart`
- `apps/mobile/lib/features/gameplay/big_walker/widgets/big_walker_hud.dart`
- `apps/mobile/lib/features/gameplay/big_walker/widgets/big_walker_player_chips.dart`
- при необходимости: новые `widgets/` и `painters/`

### 5. Обновить AGENTS.md
Добавить правило, что для игровых экранов запрещён placeholder-визуал и дефолтные Material-кнопки без кастомизации.

## Предлагаемая структура ассетов
```text
apps/mobile/assets/design/big_walker_reference/
  01_settings_modal_reference.png
  02_match_screen_single_token_reference.png
  03_match_screen_multi_token_reference.png
  04_dice_roll_state_reference.png
  05_next_turn_overlay_reference.png
  06_match_screen_alt_layout_reference.png
  07_player_select_screen_reference.png
  08_pause_menu_reference.png
  09_victory_modal_reference.png
  10_rules_modal_reference.png
```

## Маппинг экранов на фичи
- `01_settings_modal_reference.png` → settings modal
- `02_match_screen_single_token_reference.png` → основной боевой экран
- `03_match_screen_multi_token_reference.png` → вариант экрана с несколькими фишками / multiplayer composition
- `04_dice_roll_state_reference.png` → состояние броска кубика
- `05_next_turn_overlay_reference.png` → экран перехода хода
- `06_match_screen_alt_layout_reference.png` → дополнительная композиция матча
- `07_player_select_screen_reference.png` → выбор игроков 2–6 перед стартом
- `08_pause_menu_reference.png` → pause/in-game menu
- `09_victory_modal_reference.png` → победное модальное окно
- `10_rules_modal_reference.png` → правила игры

## Что Codex должен реализовать кодом, а не брать из мокапов
1. Все тексты как обычные Flutter Text / i18n strings.
2. Все кнопки как переиспользуемые custom widgets.
3. Все модалки как реальные overlay/dialog widgets.
4. Поле и маршрут — кодом или через `CustomPainter`, не как плоский screenshot.
5. Фишки игроков — отдельные виджеты/asset references, а не часть скриншота.
6. Dice state — анимировать существующей логикой.
7. Переход хода — отдельный overlay с fade/scale/pulse.

## Важные визуальные требования
- Не использовать дефолтные `ElevatedButton`, `OutlinedButton`, `Slider`, `DropdownButton` как финальный внешний вид.
- Не оставлять прямоугольные плашки без декоративной обработки.
- Экран должен выглядеть как цельная fantasy game scene.
- Сохранить mobile readability.
- Поддержать Android + iPhone landscape.
- Использовать общие design tokens для:
  - colors
  - radii
  - spacing
  - blur/glow
  - animation durations

## Acceptance criteria
1. Экран матча визуально близок к референсам.
2. Выбор игроков 2–6 оформлен как отдельный красивый экран.
3. Есть состояния:
   - idle
   - dice roll
   - token movement
   - next turn
   - victory
   - rules
   - settings
   - pause
4. Фишки двигаются по клеткам по существующей логике.
5. Кубик анимирован.
6. Активный игрок визуально подсвечен.
7. Нет placeholder UI.
8. Вся механика текущего MVP сохранена.



## Критичное несоответствие, которое нужно учесть
В текущем коде поле Big Walker рассчитано на `8 x 5 = 40` клеток через `BigWalkerTokens.cols`, `rows` и `totalCells`.
Часть референсов визуально показывает другое количество ячеек и декоративную нумерацию.
Поэтому Codex должен трактовать номера на мокапах как художественную часть, а не как источник истинных правил.
Если цель проекта — перейти на 75 клеток, нужно осознанно обновить:
- `BigWalkerTokens.cols`
- `BigWalkerTokens.rows`
- `BigWalkerTokens.totalCells`
- логику построения маршрута
- layout/route painter
При этом сам принцип игры сохраняется: бросок кубика, пошаговое движение, смена хода, победа на последней клетке.

## Готовый мастер-промпт для Codex
См. файл `codex_master_prompt_ru.txt`.

## AGENTS.md patch
См. файл `agents_patch_big_walker.md`.