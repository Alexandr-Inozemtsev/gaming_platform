/**
 * Назначение файла: выполнить smoke-проверки ключевых API операций и store-потока Prompt G.
 * Роль в проекте: быстро подтвердить, что auth/catalog/store/inventory/matches работают согласованно.
 * Основные функции: register/login, skus, sandbox purchase, apply skin, inventory read.
 * Связи с другими файлами: проверяет services/api/src/app.mjs.
 * Важно при изменении: сохранять короткий путь проверки бизнес-ценности магазина MVP.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('smoke API + store inventory flow', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const user = app.auth.register({ email: 'smoke@test.dev', password: 'secret01' });
  const login = app.auth.login({ email: 'smoke@test.dev', password: 'secret01' });
  const skus = app.store.skus();
  const cosmeticSku = skus.items.find((x) => x.type === 'COSMETIC').sku;

  const purchase = app.store.purchaseSandbox({ userId: user.id, sku: cosmeticSku });
  const apply = app.store.applySkin({ userId: user.id, sku: cosmeticSku });
  const inventory = app.users.inventory({ userId: user.id });

  assert.equal(Boolean(login.accessToken), true);
  assert.equal(Array.isArray(skus.items), true);
  assert.equal(purchase.ok, true);
  assert.equal(apply.appliedSku, cosmeticSku);
  assert.equal(inventory.some((i) => i.sku === cosmeticSku), true);
});
