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

Если `curl.exe` на `127.0.0.1:18080` возвращает `Failed to connect`, значит на хосте никто не слушает порт `18080`.

Минимальный способ быстро проверить запуск WebGL runtime локально:
```powershell
# 1) Перейти в ПАПКУ-РОДИТЕЛЬ (где есть подпапка WebGLBuild)
cd C:\unity_builds\big_walker_webgl

# 2) Проверить, что подпапка WebGLBuild действительно есть
Get-ChildItem

# 3) Поднять простой HTTP-сервер на 18080 (держите это окно открытым)
py -m http.server 18080

# 4) Проверить с хоста и эмулятора
curl.exe -I http://127.0.0.1:18080/
# в эмуляторе: http://10.0.2.2:18080/
```

### Что открывать в первом окне и что во втором

**Окно 1 (PowerShell #1):** Unity WebGL сервер.
```powershell
cd C:\unity_builds\big_walker_webgl
py -m http.server 18080
```

После `Serving HTTP on :: port 18080` оставьте это окно PowerShell открытым.
Это и есть признак, что локальный WebGL-сервер запущен успешно.

**Окно 2 (PowerShell #2):** запуск Flutter-приложения:
```powershell
cd C:\Users\alexp\StudioProjects\gaming_platform\apps\mobile
flutter run -d emulator-5554 `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 `
  --dart-define=WS_URL=ws://10.0.2.2:3001 `
  --dart-define=UNITY_BIG_WALKER_URL=http://10.0.2.2:18080 `
  --dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=in_app
```

Если в логах есть `INSTALL_FAILED_INSUFFICIENT_STORAGE`, это ошибка нехватки места в эмуляторе Android.

Важно: если после этого Flutter пишет `Uninstalling old version...` и затем приложение запускается (появились VM Service/DevTools ссылки), текущий запуск уже успешен.

Если ошибка повторяется постоянно:
```powershell
# удалить приложение из эмулятора
adb uninstall com.example.tabletopplatform_mobile

# очистить сборку и поставить заново
flutter clean
flutter pub get
flutter run -d emulator-5554
```

Если всё равно не помогает — в Android Studio откройте Device Manager и сделайте `Wipe Data` для эмулятора.

Если в эмуляторе Unity-заставка висит (лого и полоска загрузки без прогресса):

1. Смотрите логи в окне `py -m http.server 18080` — должны быть успешные `200` на файлы из `WebGLBuild/Build/`.
2. Проверьте, что в билде есть ожидаемые артефакты:
```powershell
cd C:\unity_builds\big_walker_webgl
Get-ChildItem .\WebGLBuild\Build
curl.exe -I http://127.0.0.1:18080/WebGLBuild/Build/WebGLBuild.framework.js
curl.exe -I http://127.0.0.1:18080/WebGLBuild/Build/WebGLBuild.data
curl.exe -I http://127.0.0.1:18080/WebGLBuild/Build/WebGLBuild.wasm
```
3. Если в билде файлы только в сжатом виде (`.br`, `.gz`, `.unityweb`) и загрузка зависает, пересоберите Unity WebGL с:
   - `Compression Format = Disabled`, или
   - `Decompression Fallback = On` (в Publishing Settings),
   затем повторно поднимите сервер.
4. Для отладки можно запускать во внешнем браузере:
```powershell
cd C:\Users\alexp\StudioProjects\gaming_platform\apps\mobile
flutter run -d emulator-5554 `
  --dart-define=UNITY_BIG_WALKER_URL=http://10.0.2.2:18080 `
  --dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=external
```

Если видите `No pubspec.yaml file found`, значит команда запущена не из `apps/mobile`.

### Пошагово для новичка (Windows): что где запускать

Ничего закрывать не нужно, пока не закончите проверку.

1) **Окно PowerShell #1** (сервер Unity WebGL):
```powershell
cd C:\unity_builds\big_walker_webgl
py -m http.server 18080
```
Оставьте это окно открытым.

2) **Окно PowerShell #2** (проверка файлов WebGL):
```powershell
cd C:\unity_builds\big_walker_webgl
curl.exe -I http://127.0.0.1:18080/WebGLBuild/Build/WebGLBuild.framework.js
curl.exe -I http://127.0.0.1:18080/WebGLBuild/Build/WebGLBuild.data
curl.exe -I http://127.0.0.1:18080/WebGLBuild/Build/WebGLBuild.wasm
```
Ожидаемый результат: везде `HTTP/1.0 200 OK` или `HTTP/1.1 200 OK`.
Если все три команды вернули `200 OK`, значит Unity WebGL сервер и файлы настроены правильно.

3) **Окно PowerShell #3** (запуск Flutter):
```powershell
cd C:\Users\alexp\StudioProjects\gaming_platform\apps\mobile
flutter run -d emulator-5554 `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 `
  --dart-define=WS_URL=ws://10.0.2.2:3001 `
  --dart-define=UNITY_BIG_WALKER_URL=http://10.0.2.2:18080 `
  --dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=external
```

Нужно ли закрывать эмулятор? **Нет**, не нужно.  
Нужно ли перезапускать сервер `py -m http.server`? **Нет**, только если вы изменили файлы билда или сервер упал.

Если в WebView видите ошибку `Unable to load file Build/WebGLBuild.framework.js`, значит `index.html` ссылается на несуществующий файл сборки.

Проверьте артефакты в папке билда:
```powershell
cd C:\path\to\actual\webgl\build
Get-ChildItem .\Build
Select-String -Path .\index.html -Pattern "Build/.*framework.js|Build/.*data|Build/.*wasm"
```

Что должно совпадать:
- имя файлов в `Build\` (например `WebGLBuild.framework.js`, `WebGLBuild.data`, `WebGLBuild.wasm`);
- ссылки в `index.html` на эти же имена.
- если URL в приложении `.../WebGLBuild/`, то сервер должен быть поднят из **родительской** папки, где существует путь `.\WebGLBuild\Build\...`.

Если имена не совпадают — пересоберите Unity WebGL или исправьте ссылки в `index.html` под фактические имена файлов в `Build\`.

Если видите ошибку `abort("both async and sync fetching of the wasm failed")`:

1. Проверьте MIME и размер wasm:
```powershell
curl.exe -I http://127.0.0.1:18080/WebGLBuild/Build/WebGLBuild.wasm
```
Должно быть `Content-Type: application/wasm` и ненулевой `Content-Length`.

2. Запустите сервер не через `py -m http.server`, а через Node-сервер (часто стабильнее для Unity WebGL):
```powershell
cd C:\unity_builds\big_walker_webgl
npx http-server . -p 18080 --cors
```
Если видите `Available on: ... http://127.0.0.1:18080`, сервер запущен успешно.

3. Если проблема сохраняется, пересоберите Unity WebGL:
- `Compression Format = Disabled`
- `Decompression Fallback = On`
- отключить Brotli/Gzip для локальной отладки.

Если открывается пустая сцена (небо/плоскость), но ошибок загрузки нет:
- это означает, что WebGL runtime запустился, но в билд попала не та Unity-сцена (например, пустая test/demo-сцена);
- Flutter/эмулятор в этом случае работают корректно, проблема в содержимом Unity билда.

Что сделать:
1. Откройте Unity-проект Big Walker.
2. Проверьте `Build Settings -> Scenes In Build`: первой должна быть игровая сцена Big Walker.
3. Соберите WebGL заново в `C:\unity_builds\big_walker_webgl\WebGLBuild`.
4. Перезапустите локальный сервер и Flutter-приложение.

### Unity чек-лист “кнопка за кнопкой” (пересборка WebGL)

1. Откройте Unity Hub → выберите проект Big Walker → `Open`.
2. В Unity: `File` → `Build Settings...`.
3. В `Platform` выберите `WebGL` → нажмите `Switch Platform` (если кнопка активна).
4. В `Scenes In Build`:
   - откройте игровую сцену Big Walker (`File` → `Open Scene...`);
   - нажмите `Add Open Scenes`;
   - убедитесь, что эта сцена стоит первой в списке (index 0).
5. В окне `Build Settings` нажмите `Player Settings...`:
   - `Publishing Settings` → `Compression Format` = `Disabled` (для локальной отладки);
   - `Publishing Settings` → `Decompression Fallback` = `On`;
   - сохраните настройки.
6. Вернитесь в `Build Settings` → нажмите `Build`.
7. Укажите папку сборки: `C:\unity_builds\big_walker_webgl\WebGLBuild`.
8. Дождитесь окончания билда и проверьте, что появились файлы:
   - `WebGLBuild\Build\WebGLBuild.framework.js`
   - `WebGLBuild\Build\WebGLBuild.data`
   - `WebGLBuild\Build\WebGLBuild.wasm`
9. В PowerShell запустите сервер из родительской папки:
```powershell
cd C:\unity_builds\big_walker_webgl
npx http-server . -p 18080 --cors
```
10. Запустите Flutter (в отдельном окне):
```powershell
cd C:\Users\alexp\StudioProjects\gaming_platform\apps\mobile
flutter run -d emulator-5554 `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 `
  --dart-define=WS_URL=ws://10.0.2.2:3001 `
  --dart-define=UNITY_BIG_WALKER_URL=http://10.0.2.2:18080 `
  --dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=external
```

#### Важно для Unity 6.3 (Build Profiles)

В Unity 6.x вместо старого окна `Build Settings` используется `Build Profiles` (как у вас на скриншоте).

Актуальные шаги для Unity 6.3:
1. `File` → `Build Profiles`.
2. Слева выберите `Web` и убедитесь, что статус `Active`.
3. В блоке `Scene List` оставьте игровой уровень Big Walker (не `SampleScene`).
4. Нажмите `Player Settings` (вкладка вверху окна Build Profiles).
5. В `Publishing Settings` выставьте:
   - `Compression Format = Disabled` (для локальной отладки),
   - `Decompression Fallback = On`.
6. Вернитесь в `Build Profiles` и нажмите `Build`.
7. Папка вывода: `C:\unity_builds\big_walker_webgl\WebGLBuild`.

Если в проекте есть только `Scenes/SampleScene` и нет сцены Big Walker:
- это значит, что у вас открыт базовый/пустой Unity-проект без игрового контента Big Walker;
- Flutter-часть не может “создать” эту сцену автоматически — нужен исходник Unity-сцены от команды проекта.

Быстрая проверка в Unity:
1. В окне `Project` введите в поиске: `t:Scene`.
2. Если видите только `SampleScene`, то игровых сцен в проекте действительно нет.

Что делать дальше:
1. Получить правильный Unity-проект (или пакет) с Big Walker сценами.
2. Импортировать его в текущий Unity-проект.
3. После импорта добавить игровую сцену в `Scene List` и собрать WebGL заново.

### Где Unity-проект Big Walker в этом репозитории

В текущем репозитории обычно лежит **не полный Unity-проект**, а handoff-материалы:
- `codex_handoff_big_walker/` (референсы и документы);
- `big_walker_codex_handoff.zip` (через Git LFS, может быть только указатель).

Если `big_walker_codex_handoff.zip` открывается как текст `version https://git-lfs.github.com/spec/v1`, значит сам архив не скачан.

Чтобы получить архив из LFS:
```bash
git lfs install
git lfs pull
```

Как открыть через Unity Hub, если у вас есть полноценный Unity-проект:
1. Распакуйте архив (или получите папку проекта).
2. Убедитесь, что в корне есть `Assets/`, `Packages/`, `ProjectSettings/`.
3. Unity Hub → `Open` / `Add` → выберите папку проекта.

### Важно: что может сделать AI-ассистент, а что нет

- Я могу написать код/скрипты Unity (C#), структуру сцены, логику игры, UI, конфиги и пошаговые инструкции.
- Я **не могу** удалённо нажимать кнопки в вашем Unity Editor и автоматически создавать сцену в вашем локальном проекте без ваших действий.
- Чтобы получить “не пустой проект”, нужен либо:
  1) исходный Unity-проект с Big Walker от вашей команды, либо
  2) реализация с нуля по ТЗ (я могу дать полный план и код, но вы применяете его в Unity локально).

Готовый минимальный стартовый набор с кодом есть в репозитории:
- `unity/big_walker_starter/README_UNITY_63_RU.md`
