# Назначение: inventory и правила применения reusable UI kit.

## Base components
- Button (primary/secondary/ghost; sm/md/lg; loading/disabled).
- Chip / FilterChip.
- Badge / StatusBadge.
- Panel / Surface / Card.
- TextInput/SearchInput (через общий стиль полей).
- EmptyState, ErrorState, LoadingState, ReconnectBanner, OfflineBanner.

## Navigation
- TopBar / ScreenHeader.
- Back action в gameplay mode.
- ContextActionGroup через `Wrap` с кнопками.

## Gameplay domain
- FeaturedGameBanner.
- GameCard.
- TurnIndicator.
- TimerIndicator.
- Базовые блоки для HUD/ActionBar/ScorePanel под расширение.

## Production rules
- Touch target: минимум 44dp.
- Без random hardcode значений: только tokens.
- Состояния selected/disabled/loading/error обязательны для интерактивных контролов.
- Поведение ориентировано на touch, hover не является базовым сценарием.
