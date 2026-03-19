/**
 * Назначение файла: проверить endpoint-эквиваленты магазина и инвентаря для Prompt G.
 * Роль в проекте: гарантировать корректность sku catalog, sandbox purchase и предупреждения для ru_by.
 * Основные функции: проверка /store/skus модели и добавления item в inventory.
 * Связи с другими файлами: использует services/api/src/app.mjs.
 * Важно при изменении: не ломать контракт SKU types (GAME_LICENSE/COSMETIC).
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('store skus возвращает warning для ru_by', () => {
  const app = createApiApp({ config: { REGION_MODE: 'ru_by' } });
  const skus = app.store.skus();
  assert.equal(Boolean(skus.warning), true);
  assert.equal(skus.items.some((x) => x.type === 'GAME_LICENSE'), true);
  assert.equal(skus.items.some((x) => x.type === 'COSMETIC'), true);
});

test('sandbox purchase добавляет item в inventory', () => {
  const app = createApiApp();
  const user = app.auth.register({ email: 'store@test.dev', password: 'secret01' });
  const sku = app.store.skus().items[0].sku;
  app.store.purchaseSandbox({ userId: user.id, sku });
  const inventory = app.users.inventory({ userId: user.id });
  assert.equal(inventory.length, 1);
  assert.equal(inventory[0].sku, sku);
});
