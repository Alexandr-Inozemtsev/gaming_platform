# Мобильное приложение (Flutter)

## Назначение
Этот модуль содержит MVP-клиент TabletopPlatform с экранами, состоянием, интеграцией API/WebSocket и переключением языка.

## Параметры окружения
- `API_BASE_URL=http://localhost:3000`
- `WS_URL=ws://localhost:3001`
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
