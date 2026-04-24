# Big Walker Starter (Unity 6.3) — быстрый старт для новичка

Этот набор даёт **рабочую минимальную игру** (трек, 2 фишки, бросок кубика, победа) без префабов и сложной сцены.

## Что внутри
- `Assets/Scripts/BigWalkerSceneBootstrap.cs` — автоматически создаёт камеру, свет и контроллер.
- `Assets/Scripts/BigWalkerGameController.cs` — логика игры и HUD.

## Шаги (Unity 6.3)

1. **Создайте новый проект** в Unity Hub (Template: 3D Core).
2. Откройте папку проекта в проводнике и скопируйте папку `Assets/Scripts` из этого каталога:
   - из: `unity/big_walker_starter/Assets/Scripts`
   - в: `<ваш Unity проект>/Assets/Scripts`
   - вариант через PowerShell:
```powershell
# запускать в PowerShell из корня репозитория gaming_platform
Copy-Item -Recurse -Force .\unity\big_walker_starter\Assets\Scripts\* "<ПУТЬ_К_UNITY_ПРОЕКТУ>\Assets\Scripts\"
```
Пример для вашего случая:
```powershell
# 1) Перейти в корень репозитория (где есть папка unity/)
cd C:\Users\alexp\StudioProjects\gaming_platform

# 2) Проверить, что исходная папка со скриптами существует
Test-Path .\unity\big_walker_starter\Assets\Scripts

# 3) Создать целевую папку и скопировать файлы
New-Item -ItemType Directory -Force "C:\Personal\UnityGame\BigWalkerStarter\Assets\Scripts" | Out-Null
Copy-Item -Recurse -Force .\unity\big_walker_starter\Assets\Scripts\* "C:\Personal\UnityGame\BigWalkerStarter\Assets\Scripts\"
```
3. В Unity дождитесь импорта скриптов.
4. В `Hierarchy`:
   - `Right Click` → `Create Empty`
   - назовите объект `Bootstrap`
   - в `Inspector` нажмите `Add Component` → добавьте `BigWalkerSceneBootstrap`.
   - если не видно `Inspector`: `Window` → `General` → `Inspector`.
   - если не видно `Hierarchy`: `Window` → `General` → `Hierarchy`.
5. Нажмите `Play` — появится экран выбора фишки (6 вариантов), выбора числа игроков (2..6) и кнопка `START GAME`.
   - если `Play` не запускается: откройте `Console` и исправьте красные ошибки (warnings можно игнорировать).
   - если кнопка видна, но не нажимается: убедитесь, что в Hierarchy есть `EventSystem` (скрипт добавляет его автоматически в новой версии).
   - если в Console ошибка `InvalidOperationException ... switched active Input handling to Input System package`:
     обновите скрипты из этого репозитория (новая версия автоматически подбирает правильный UI Input Module).
   - в новой версии есть пошаговая анимация движения фишек по клеткам (подскок + squash/stretch).
   - добавлена анимация броска кубика с фиксацией итоговой грани (1..6).
   - камера автоматически смещается к активной фишке, чтобы ходы были видны лучше.

## Как подключить свои 3D ассеты персонажей (вместо примитивов)
`BigWalkerGameController` поддерживает 6 опциональных слотов ассетов (`Character Assets (optional)`).

1. Импортируйте ваши FBX/Prefab модели в Unity (`Assets/Art/Characters/...`).
2. Откройте объект `BigWalkerGameController` в `Hierarchy`.
3. В `Inspector` найдите блок `Character Assets (optional)` и установите `Size = 6`.
4. Для каждого элемента (0..5) задайте:
   - `Title` (имя архетипа),
   - `Character Prefab` (ваш prefab модели),
   - `World Scale` (масштаб на поле),
   - `World Rotation Euler` (базовый поворот).
5. Нажмите `Play`: при наличии `Character Prefab` будет создана 3D-модель; если слот пустой — используется fallback-примитив.

## Сборка WebGL (для запуска из Flutter)
1. `File` → `Build Profiles`
2. Выберите `Web` → `Active`
3. В `Scene List` добавьте текущую сцену (где есть `Bootstrap`).
4. `Player Settings` → `Publishing Settings`:
   - `Compression Format = Disabled`
   - `Decompression Fallback = On`
5. `Build` в папку:
   - `C:\unity_builds\big_walker_webgl\WebGLBuild`

## Запуск локального сервера
```powershell
cd C:\unity_builds\big_walker_webgl
npx http-server . -p 18080 --cors
```

## Запуск Flutter с Unity runtime
```powershell
cd C:\Users\alexp\StudioProjects\gaming_platform\apps\mobile
flutter run -d emulator-5554 `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 `
  --dart-define=WS_URL=ws://10.0.2.2:3001 `
  --dart-define=UNITY_BIG_WALKER_URL=http://10.0.2.2:18080 `
  --dart-define=UNITY_BIG_WALKER_LAUNCH_MODE=external
```

## Важно
Это **starter-версия** (демо-логика). Для production-версии нужны:
- арт/анимации,
- полноценные правила,
- синхронизация с backend матча.

## Режим “проведи меня пошагово”

Если идёте с ассистентом вживую, двигайтесь так:
1. Выполните только шаг №1 из раздела `Шаги (Unity 6.3)`.
2. Напишите: `готово 1`.
3. Затем делайте шаг №2 и пишите: `готово 2`.
4. Продолжайте в таком формате до сборки и запуска.
