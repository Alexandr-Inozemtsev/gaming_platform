# Назначение: asset strategy, naming и prompts для генерации визуалов.

## Asset manifest
Источник: `assets/design/asset-manifest.json`.
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
SVG-заглушки: `assets/design/placeholders/*.svg`.

## Prompts
См. `assets/design/image-prompts.md` (покрывает 11 экранов: visual goal, art direction, composition, dominant colors, object list, bg treatment, export format, prompt).
