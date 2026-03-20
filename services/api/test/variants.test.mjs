/**
 * Назначение файла: проверить редактор вариантов правил v0 на уровне API-домена без HTTP-слоя.
 * Роль в проекте: подтвердить, что варианты валидируются, публикуются и реально влияют на параметры матча.
 * Основные функции: тесты create/update/validate/publish и проверка применения boardSize в созданном матче.
 * Связи с другими файлами: использует services/api/src/app.mjs и опирается на rules-engine через matches.create.
 * Важно при изменении: критерий «вариант влияет на правила» должен оставаться истинным для всех поддерживаемых игр.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('variants: validate блокирует publish при ошибках', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const author = app.auth.register({ email: 'variant-author@test.dev', password: 'secret01' });

  const draft = app.variants.createDraft({
    userId: author.id,
    gameId: 'tile_placement_demo',
    boardSize: 4,
    winCondition: 'invalid condition',
    scoringMultipliers: { adjacency: 1.2 },
    turnTimer: 30
  });

  const validation = app.variants.validate({ variantId: draft.id, userId: author.id });
  assert.equal(validation.ok, false);
  assert.equal(validation.errors.includes('WIN_CONDITION_UNSUPPORTED'), true);

  assert.throws(
    () => app.variants.publish({ variantId: draft.id, userId: author.id }),
    (error) => error.code === 'VARIANT_VALIDATION_FAILED'
  );
});

test('variants: published variant влияет на размер поля в матче', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const author = app.auth.register({ email: 'variant-publisher@test.dev', password: 'secret01' });
  const p2 = app.auth.register({ email: 'variant-player-2@test.dev', password: 'secret01' });

  const draft = app.variants.createDraft({
    userId: author.id,
    gameId: 'tile_placement_demo',
    boardSize: 6,
    winCondition: 'highest_score',
    scoringMultipliers: { adjacency: 1.5 }
  });

  const validation = app.variants.validate({ variantId: draft.id, userId: author.id });
  assert.equal(validation.ok, true);

  const publish = app.variants.publish({ variantId: draft.id, userId: author.id });
  assert.equal(typeof publish.privateLink, 'string');

  const match = app.matches.create({
    gameId: 'tile_placement_demo',
    players: [author.id, p2.id],
    variantId: draft.id
  });

  assert.equal(match.variantId, draft.id);
  assert.equal(match.maxMoves, 36);
  assert.equal(match.gameState.size, 6);
  assert.equal(match.gameState.grid.length, 6);
});
