# Назначение: правила адаптации landscape layout для iOS/Android и разных классов ширины.

## Размерные классы
- Compact landscape: `<900w` или `<430h`.
- Regular landscape: `900-1179w`.
- Large landscape: `>=1180w`.

## Правила collapse/expand
- Compact: side panels становятся overlay sheet; chat/log сворачиваются; long text ограничен 2-3 строками.
- Regular: одна side panel закреплена, secondary контент в collapsible блоках.
- Large: двухпанельный режим (gameplay + info panel), расширенные списки и метрики.

## Long text
- Заголовки: 1-2 строки + ellipsis.
- Вторичный текст: maxLines 2-3.
- Критичные сообщения (error/reconnect): всегда полнотекстово, но в scrollable container.

## System overlays
- Reconnect/offline баннеры фиксируются сверху с учётом safe area.
- Modal/sheet учитывают gesture зоны снизу и справа/слева.
