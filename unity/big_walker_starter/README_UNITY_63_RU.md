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
3. В Unity дождитесь импорта скриптов.
4. В `Hierarchy`:
   - `Right Click` → `Create Empty`
   - назовите объект `Bootstrap`
   - в `Inspector` нажмите `Add Component` → добавьте `BigWalkerSceneBootstrap`.
5. Нажмите `Play` — появится минимальная игра с кнопкой `Бросить кубик`.

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
