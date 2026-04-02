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
- Unity Big Walker launch PoC:
  - введён runtime adapter с режимами запуска `in_app`/`external`;
  - выделен `UnityRuntimeSessionManager` для session-init и lifecycle telemetry (очистка AppState);
  - по умолчанию используется `external` (`LaunchMode.externalApplication`) для максимальной совместимости Unity WebGL на Android;
  - перед запуском выполняется `runtime-sdk/v1` валидация session-init payload;
  - lifecycle события `runtime.session.started` / `runtime.session.ended` отправляются в analytics через runtime envelope.
  - добавлен preflight check `/runtime-sdk/v1/events`: при недоступности contract endpoint запуск Unity не блокируется, но runtime telemetry отключается с явным warning в UI.

## Ограничения MVP
- Для недоступного API список игр возвращается из fallback-мока.
- Реальный board zoom/pan пока заменён визуальным плейсхолдером.
- Для запуска в веб/эмуляторе требуется установленный Flutter SDK.

## Ручные шаги владельца
1. Поднять backend (`services/api`, `services/realtime`) и infra.
2. Передать `--dart-define=API_BASE_URL=...` и `--dart-define=WS_URL=...`.
3. Пройти сценарий: login -> catalog -> create room -> room -> store purchase -> settings language switch.
4. Для Unity Big Walker при необходимости переключить режим запуска:
   - `--dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=external` (default)
   - `--dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=in_app`

## Диагностика Unity WebGL (Android)
Если в браузере появляется ошибка вида `both async and sync fetching of the wasm failed`, проблема обычно в раздаче Unity-бандла, а не в Flutter-клиенте:
- URL должен вести на папку билда (`.../WebGLBuild/`), а не на корень файлового сервера;
- сервер должен корректно отдавать `.wasm`/`.data`/`.framework.js` и сжатые артефакты (`.gz`/`.br`) с корректными заголовками;
- при локальной разработке используйте отдельный статический сервер для Unity-билда и проверяйте открытие `index.html` этого билда напрямую в браузере.
