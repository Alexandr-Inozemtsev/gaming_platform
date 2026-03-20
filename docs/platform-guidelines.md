# Назначение: platform-specific guidelines для iOS и Android без развала общего UI слоя.

## iOS
- Учитывать notch/Dynamic Island в landscape через MediaQuery padding.
- Системные жесты (home indicator) не перекрывать CTA.
- Микро-анимации чуть мягче (emphasized easing) для platform feel.

## Android
- Учитывать camera cutouts и variative status/navigation bars.
- На compact-устройствах по умолчанию включать panel-collapsed mode.
- Учитывать более широкий диапазон плотностей и aspect ratios.

## Общие правила
- Один token-layer для обеих платформ.
- Без web-only assumptions и hover-first UX.
- При расхождении платформенных паттернов отделять platform specifics от общего UI kit.
