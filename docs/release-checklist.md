# Чеклист релиза MVP (Prompt P)

## Цель
Проверить, что проект можно поднять «одной кнопкой», выполнить smoke-сценарий и запустить Flutter на Android/iOS эмуляторах.

## One-button команды
```bash
npm install
scripts/dev-up.sh
```

Скрипт `scripts/dev-up.sh` выполняет:
1. Поднимает инфраструктуру (`infra/docker-compose.yml`).
2. Запускает backend runtime (api/realtime/admin/rules-engine).
3. Запускает `scripts/smoke.sh`.
4. Показывает команды запуска Flutter для Android/iOS.

## Smoke сценарий
```bash
scripts/smoke.sh
```

Проверяется цепочка:
- login
- create private room (match)
- start tile game vs bot (первый ход)
- store sandbox purchase
- apply skin

## Ручной запуск (если нужен пошаговый контроль)
```bash
cd infra && docker compose -f docker-compose.yml up -d
REGION_MODE=global API_PORT=3000 node services/api/src/runtime.mjs
REGION_MODE=global REALTIME_PORT=3001 node services/realtime/src/runtime.mjs
REGION_MODE=global ADMIN_PORT=3002 node services/admin/src/runtime.mjs
REGION_MODE=global RULES_ENGINE_PORT=3003 node services/rules-engine/src/runtime.mjs
cd apps/mobile && flutter run -d emulator-5554
cd apps/mobile && flutter run -d "iPhone 15"
```

## Параметры
- `ANDROID_DEVICE=emulator-5554`
- `IOS_DEVICE="iPhone 15"`
- `REGION_MODE=global|ru_by`

## Итоговый UI-чек
- ✅ Home
- ✅ Catalog
- ✅ Room
- ✅ Game
- ✅ Store

## Токены релизного статуса
- `release.ok=#4EE59A`
- `release.fail=#FF5C7A`

## Публикация бинарников
- Публикуйте бинарные asset-паки (`.webp`, `.png`, `.ttf` и др.) отдельным шагом **после merge** в основную ветку.
- PR в этом репозитории должен оставаться binary-free, если это не согласовано отдельно.
- Перед публикацией бинарников проверьте, что `ASSET_BASE_URL` зафиксирован для dev/stage/prod и runtime успешно резолвит remote URL.

## Остановка
```bash
scripts/dev-down.sh
```
