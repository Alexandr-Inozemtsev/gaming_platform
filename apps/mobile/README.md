# Мобильное приложение (Flutter)

## Назначение
Этот модуль содержит MVP-клиент TabletopPlatform с экранами, состоянием, интеграцией API/WebSocket и переключением языка.

## Параметры окружения
- `API_BASE_URL=http://localhost:3000`
- `WS_URL=ws://localhost:3001`
- `ASSET_BASE_URL=http://localhost:8080`
- `REGION_MODE=global|ru_by`
- `LANG=ru` (по умолчанию)

## Экраны MVP
- Onboarding (минимально в welcome-потоке)
- Auth (login/register)
- Home
- Catalog
- Game Room
- Store (Games/Skins)
- Profile
- Settings (язык + privacy блок)

## ASCII-макеты
```text
HOME:
+-------------------------+
| Continue: Match #1      |
| [Play] [Create Room]    |
| Store teaser: new skins |
+-------------------------+

STORE:
+-------------------------+
| [Games] [Skins]         |
| Game Pack: Buy (sandbox)|
| Dice Skin: Try/Buy      |
+-------------------------+

ROOM:
+-------------------------+
| Board area (zoom/pan)   |
| Log | Chat | Actions    |
+-------------------------+
```

## Дизайн-токены
См. `lib/theme/tokens.dart`.

## Prompt D / Settings
```text
[SETTINGS] Privacy • Block list • Report
```

## Запуск
```bash
flutter doctor
flutter pub get
flutter run
```

## i18n
RU/EN переключаются в Settings.


## Prompt F: ASCII
```text
TILE:
[Grid] tap cell -> place tile -> confirm

R&W:
Dice: [3][2]  Sheet: tap to mark
```

## Prompt F токены
- `board.gridLine = #22304D`
- `board.highlight = #6EE7FF`


## Prompt G
`Store -> Skins -> [Try] [Buy] [Apply]`

- `store.priceTag = #FFD166`
- `store.badgeNew = #6EE7FF`

## Prompt H
`Editor: [Board Size] [Scoring] [Validate] [Test] [Publish]`

- `editor.warning = #FFB020`
- `editor.sectionTitle = 18`

## Prompt I
`[Video Overlay] [Cam off] [Mic on] [Hang up]`

- `video.overlayBg = rgba(0,0,0,0.35)`
- `video.tileRadius = 12`

## Prompt J
`Admin -> Analytics -> [Events table]`

- `analytics.chartLine = #6EE7FF`
- `analytics.axis = #9AA4B2`

## Prompt K
`CI pipeline: lint -> unit -> integration -> e2e`

- `qa.pass = #4EE59A`
- `qa.fail = #FF5C7A`


## Troubleshooting (Windows / Git Bash)
- Если вы уже находитесь в `.../gaming_platform/apps/mobile`, **не выполняйте повторно** `cd apps/mobile`.
- Корректная последовательность запуска из корня репозитория:
```bash
cd apps/mobile
flutter clean
flutter pub get
flutter run -d emulator-5554
```
- Если компилятор показывает `<<<<<<<`, `=======`, `>>>>>>>`, значит в файлах остались merge conflict markers.
  Проверка из корня репозитория:
```bash
rg -n "^(<<<<<<<|=======|>>>>>>>)" apps/mobile/lib
```
  После исправления выполните повторно `flutter clean && flutter pub get && flutter run`.
- Если видите `SocketException ... address = 10.0.2.2` при старте, это означает, что мобильный клиент не может достучаться до backend API с хоста.
  1. Поднимите локальную инфраструктуру из корня репозитория:
  ```bash
  cd infra
  docker compose up -d
  ```
  > Важно: `docker compose up -d` в `infra/` поднимает API/WS/БД, но **не** поднимает Unity WebGL runtime на `:18080`.
  2. Вернитесь в Flutter-проект (`apps/mobile`), иначе получите `No pubspec.yaml file found`:
  ```bash
  cd ..
  cd apps/mobile
  ```
  3. Запустите Flutter с явными `dart-define` для Android-эмулятора (важно: используйте реальные переносы строк, не вставляйте `\n` как текст):
  ```bash
  flutter run -d emulator-5554 \
    --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
    --dart-define=WS_URL=ws://10.0.2.2:3001 \
    --dart-define=UNITY_BIG_WALKER_URL=http://10.0.2.2:18080 \
    --dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=in_app
  ```
  4. Если при открытии `10.0.2.2:18080` в эмуляторе браузер пишет `This site can't be reached`, значит Unity runtime не запущен на хост-машине (или слушает другой порт). Проверьте локальный процесс, который должен отдавать WebGL билд.

### Быстрый чек-лист (Windows) для `:18080` — 3 команды
```powershell
# 1) Проверить, слушает ли кто-то порт 18080 на хосте
netstat -ano | findstr :18080

# 2) Проверить, отвечает ли endpoint локально (в PowerShell используйте curl.exe, а не alias curl)
curl.exe -I http://127.0.0.1:18080/
curl.exe -I http://127.0.0.1:18080/WebGLBuild/

# 3) Из корня репозитория найти подсказки, откуда должен стартовать WebGL runtime
rg -n "UNITY_BIG_WALKER_URL|18080|WebGLBuild|WebGL" README.md apps infra -S
```
