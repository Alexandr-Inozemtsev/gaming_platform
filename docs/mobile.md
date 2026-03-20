# Mobile MVP (Flutter): состояние, API и WebSocket

## Назначение
Документ фиксирует состав мобильного клиента MVP и объясняет принятые архитектурные упрощения.

## Что реализовано
- Навигационный shell с вкладками: Home, Catalog, Room, Store, Profile, Settings.
- Auth-экран login/register.
- API-клиент для login/register/games/create match/purchase sandbox.
- WebSocket-клиент для realtime событий комнаты.
- Простая i18n RU/EN без внешних зависимостей.
- Анимации:
  - fade при переключении вкладок;
  - pulse-подсветка «твой ход».

## Ограничения MVP
- Для недоступного API список игр возвращается из fallback-мока.
- Реальный board zoom/pan пока заменён визуальным плейсхолдером.
- Для запуска в веб/эмуляторе требуется установленный Flutter SDK.

## Ручные шаги владельца
1. Поднять backend (`services/api`, `services/realtime`) и infra.
2. Передать `--dart-define=API_BASE_URL=...` и `--dart-define=WS_URL=...`.
3. Пройти сценарий: login -> catalog -> create room -> room -> store purchase -> settings language switch.
