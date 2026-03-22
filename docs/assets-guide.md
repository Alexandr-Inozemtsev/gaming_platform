# Назначение: asset strategy, naming и prompts для генерации визуалов.

## Asset manifest
Источник: `apps/mobile/assets/design/asset-manifest.json`.
Категории: icons, logos, illustrations, game_covers, textures, decorative_graphics, gameplay_objects, badges, trophies, ambient_backgrounds.

### Единая policy variant-ключей (P1)
- `variant` — это **логический профиль доставки**, а не гарантия физического формата файла.
- Базовый ключ runtime для растровых ассетов: `raster@2x` (и при необходимости `raster@3x`).
- Ключи `webp@2x`/`webp@3x` считаются legacy-совместимостью и не должны быть основными для новых записей.
- Физический файл может быть `.webp` или `.png`, если это не противоречит manifest и runtime-resolver.
- Для процедурных экранов допускается `runtime@procedural` как отдельный runtime source.

## Naming
`{screen}.{block}.{theme}.{size}@{scale}.{ext}`
Пример: `gameplay.board.bg.dark.1920x1080@3x.webp`.

## Export rules
- Иконки: SVG.
- Иллюстрации: SVG или PNG/WebP high-res.
- Текстуры/screen art: логические варианты `raster@2x`/`raster@3x` (физически PNG/WebP).
- Варианты dark-optimized обязательны.

## Fallback placeholders
SVG-заглушки: `apps/mobile/assets/design/placeholders/*.svg`.

## Prompts
См. `apps/mobile/assets/design/image-prompts.md` (покрывает 11 экранов: visual goal, art direction, composition, dominant colors, object list, bg treatment, export format, prompt).



## Binary-free режим для Codex PR
- В среде Codex PR запрещены бинарные изменения (`*.png`, `*.webp`, `*.jpg`, `*.ttf`, `*.mp4` и т.д.), иначе PR отклоняется с ошибкой `Бинарные файлы не поддерживаются`.
- Для Big Walker основной runtime-визуал должен работать без бинарных фонов: используется процедурный слой (градиенты + painter-атмосфера).
- `reference_screens` и любые PNG/WebP допускаются только как локальная сверка дизайна и не должны быть runtime dependency.
- Image-слои с бинарными файлами разрешены только как необязательный enhancement, который безопасно деградирует до `SizedBox.shrink()`.

### Контракт консистентности (обязателен для CI)
- `apps/mobile/lib/theme/game/big_walker_tokens.dart` фиксирует ключи и default variant для Big Walker (`raster@2x`).
- `apps/mobile/assets/design/asset-manifest.json` хранит каноничные variant-ключи и runtime mapping.
- `apps/mobile/lib/shared/assets/runtime_asset_pack.dart` резолвит ассеты в порядке policy (`requested -> raster@2x -> runtime@procedural -> svg -> webp@2x`).
- Скрипт `npm run validate:asset-policy` проверяет непротиворечивость tokens ↔ manifest ↔ resolver.

## Canonical manifest for mobile runtime
- Каноничный файл runtime-манифеста: `apps/mobile/assets/design/asset-manifest.json`.
- Зеркало для корневых tooling-процессов: `assets/design/asset-manifest.json` (не редактируется вручную).
- Для синхронизации зеркала используйте `npm run sync:mobile-runtime-manifest`.
- CI guard `npm run check:mobile-runtime-manifest-sync` падает при рассинхроне.

## Runtime integration
- Runtime загрузка manifest реализована в `apps/mobile/lib/shared/assets/runtime_asset_pack.dart`.
- UI-контейнеры могут запрашивать категории ассетов (например `ambient_backgrounds`) без хардкода путей.


## Cinematic Gameplay Room pack
- Для визуала “как на референсе” используйте блок `Cinematic Gameplay Room (Reference-Match Pack)` в `apps/mobile/assets/design/image-prompts.md`.
- Минимальный пакет: master background + board surface + light overlay + mic/camera/chat/settings icons + d20 burst VFX.
- Рекомендованный экспорт: WebP 1920x1080 @2x для фонов/эффектов и SVG для HUD-иконок.

### Обязательные файлы для reference-match pack
- Reference PNG для локальной сверки UI (не для финального фона экрана): `apps/mobile/assets/design/big_walker_reference/*.png` (10 файлов из handoff-пакета).
- Production background (optional enhancement, не обязательный runtime): `apps/mobile/assets/design/gameplay.bg.cinematic_room.1920x1080@2x.webp`.
- Production board texture: `apps/mobile/assets/design/gameplay.board.surface.travel_grid.1920x1080@2x.webp`.
- Production light overlay (optional enhancement): `apps/mobile/assets/design/gameplay.decor.light_rays.overlay.1920x1080@2x.webp`.
- Runtime-ключи и пути для gameplay-слоёв фиксируются в `apps/mobile/assets/design/asset-manifest.json` в секции `assets`.
