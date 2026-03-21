# Назначение: asset strategy, naming и prompts для генерации визуалов.

## Asset manifest
Источник: `apps/mobile/assets/design/asset-manifest.json`.
Категории: icons, logos, illustrations, game_covers, textures, decorative_graphics, gameplay_objects, badges, trophies, ambient_backgrounds.

## Naming
`{screen}.{block}.{theme}.{size}@{scale}.{ext}`
Пример: `gameplay.board.bg.dark.1920x1080@3x.webp`.

## Export rules
- Иконки: SVG.
- Иллюстрации: SVG или PNG/WebP high-res.
- Текстуры/screen art: PNG/WebP 2x/3x.
- Варианты dark-optimized обязательны.

## Fallback placeholders
SVG-заглушки: `apps/mobile/assets/design/placeholders/*.svg`.

## Prompts
См. `apps/mobile/assets/design/image-prompts.md` (покрывает 11 экранов: visual goal, art direction, composition, dominant colors, object list, bg treatment, export format, prompt).


## Runtime integration
- Runtime загрузка manifest реализована в `apps/mobile/lib/shared/assets/runtime_asset_pack.dart`.
- UI-контейнеры могут запрашивать категории ассетов (например `ambient_backgrounds`) без хардкода путей.


## Cinematic Gameplay Room pack
- Для визуала “как на референсе” используйте блок `Cinematic Gameplay Room (Reference-Match Pack)` в `apps/mobile/assets/design/image-prompts.md`.
- Минимальный пакет: master background + board surface + light overlay + mic/camera/chat/settings icons + d20 burst VFX.
- Рекомендованный экспорт: WebP 1920x1080 @2x для фонов/эффектов и SVG для HUD-иконок.
