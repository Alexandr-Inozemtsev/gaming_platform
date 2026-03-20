/**
 * Назначение файла: проверить подключение фикстур внутреннего генератора игр к unit tests rules-engine.
 * Роль в проекте: гарантировать, что сгенерированные definition/fixture валидны и симуляции завершаются.
 * Основные функции: чтение JSON-фикстуры tile_v1, проверка stats.total/stats.finished/definition.template.
 * Связи с другими файлами: использует services/rules-engine/fixtures/tile_v1.fixture.json и генератор tools/generator/.
 * Важно при изменении: fixture должен обновляться генератором, а тест — оставаться стабильным при изменении N_SIM.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

test('generator fixture: tile_v1 содержит завершённые симуляции', () => {
  const fixturePath = path.join(process.cwd(), 'fixtures', 'tile_v1.fixture.json');
  const raw = fs.readFileSync(fixturePath, 'utf8');
  const json = JSON.parse(raw);

  assert.equal(json.definition.template, 'tile');
  assert.equal(typeof json.stats.total, 'number');
  assert.equal(json.stats.total > 0, true);
  assert.equal(json.stats.finished, json.stats.total);
  assert.equal(Array.isArray(json.simulations), true);
  assert.equal(json.simulations.every((x) => x.finished === true), true);
});
