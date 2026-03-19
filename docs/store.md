# Store MVP: каталог SKU, инвентарь и sandbox purchase

## Назначение
Документ описывает реализацию магазина без реальных платежей для MVP.

## Backend
- SKU types: `GAME_LICENSE`, `COSMETIC`.
- Каталог: in-memory `sku_catalog`.
- Покупки: `purchases`.
- Инвентарь: `inventory`.
- Эндпоинты:
  - `GET /store/skus`
  - `POST /store/purchase-sandbox`
  - `GET /inventory`
  - `POST /store/apply-skin`

## Region mode
- Для `REGION_MODE=ru_by` возвращается предупреждение:
  - «платежный канал зависит от дистрибуции».

## Client
- Store tabs: `Games`, `Skins`, `Inventory`.
- В `Skins`: действия `[Try] [Buy] [Apply]`.
- Применение скина реально меняет внешний вид (цвет board highlight).

## Acceptance
- Sandbox purchase добавляет item в inventory.
- Apply skin меняет визуальное оформление доски/элементов.
