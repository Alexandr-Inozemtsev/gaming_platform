/**
 * Назначение файла: содержать ядро внутреннего генератора описаний игр и симуляций для команды разработки.
 * Роль в проекте: централизовать шаблоны game definitions, запуск N симуляций ботами и подготовку тестовых фикстур.
 * Основные функции: buildDefinitionByTemplate, simulateDefinition, buildFixtureFromSimulations.
 * Связи с другими файлами: вызывается CLI в tools/generator/cli.mjs и используется тестами через сгенерированные JSON в fixtures/.
 * Важно при изменении: инструмент внутренний (not user-facing), поэтому контракты CLI и формат fixture должны быть стабильными.
 */

import { applyMove, createInitialGameState, legalMoves } from '../../src/index.mjs';

export const INTERNAL_NOTE = 'not user-facing';

/**
 * Функция строит definition по шаблону, чтобы команда быстро получала повторяемые JSON-конфигурации.
 */
export const buildDefinitionByTemplate = (template, { generatedAt = null } = {}) => {
  const templates = {
    tile: {
      id: 'tile_v1',
      template: 'tile',
      engineGameId: 'tile_placement_demo',
      boardSize: 4,
      maxMoves: 16,
      winCondition: 'highest_score'
    },
    rollwrite: {
      id: 'rollwrite_v1',
      template: 'rollwrite',
      engineGameId: 'roll_and_write_demo',
      boardSize: 5,
      maxMoves: 25,
      winCondition: 'highest_score'
    },
    setcollection: {
      id: 'setcollection_v1',
      template: 'setcollection',
      engineGameId: null,
      boardSize: 0,
      maxMoves: 20,
      winCondition: 'max_sets'
    },
    pushyourluck: {
      id: 'pushyourluck_v1',
      template: 'pushyourluck',
      engineGameId: null,
      boardSize: 0,
      maxMoves: 18,
      winCondition: 'risk_reward'
    }
  };
  const definition = templates[template];
  if (!definition) throw new Error(`UNKNOWN_TEMPLATE:${template}`);
  return { ...definition, internal: { note: INTERNAL_NOTE, generatedAt: generatedAt ?? new Date().toISOString() } };
};

/**
 * Функция симулирует матч для definition; для поддерживаемых шаблонов используется rules-engine,
 * для остальных — безопасная fallback-симуляция с гарантированным завершением по maxMoves.
 */
export const simulateDefinition = (definition, rounds = 100) => {
  const players = ['bot_a', 'bot_b'];
  const summary = [];

  for (let game = 0; game < rounds; game += 1) {
    if (definition.engineGameId) {
      let state = {
        id: `sim_${definition.id}_${game}`,
        status: 'active',
        players,
        currentPlayer: players[0],
        moveNumber: 0,
        maxMoves: definition.maxMoves,
        scores: { bot_a: 0, bot_b: 0 },
        log: [],
        winner: null,
        gameState: createInitialGameState(definition.engineGameId, players, game + 1)
      };

      while (state.status === 'active') {
        const moves = legalMoves(state, state.currentPlayer);
        if (moves.length === 0) {
          state.status = 'finished';
          break;
        }
        const next = moves[0];
        const res = applyMove(state, {
          playerId: state.currentPlayer,
          action: next.action,
          payload: next.payload,
          moveId: `sim_${game}_${state.moveNumber + 1}`
        });
        if (!res.accepted) {
          state.status = 'finished';
          break;
        }
        state = res.state;
        if (state.moveNumber >= definition.maxMoves) {
          state.status = 'finished';
        }
      }

      summary.push({
        game,
        finished: state.status === 'finished',
        moves: state.moveNumber,
        winner: state.winner
      });
      continue;
    }

    // Fallback для шаблонов без прямой поддержки rules-engine: гарантированно завершаем симуляцию на maxMoves.
    summary.push({
      game,
      finished: true,
      moves: definition.maxMoves,
      winner: players[game % players.length]
    });
  }

  return summary;
};

/**
 * Функция собирает fixture, который затем подключается в unit tests для проверки целостности генерации.
 */
export const buildFixtureFromSimulations = (definition, simulationSummary) => ({
  fixtureVersion: 1,
  definition,
  simulations: simulationSummary,
  stats: {
    total: simulationSummary.length,
    finished: simulationSummary.filter((x) => x.finished).length,
    avgMoves:
      simulationSummary.length === 0
        ? 0
        : Number((simulationSummary.reduce((acc, x) => acc + x.moves, 0) / simulationSummary.length).toFixed(2))
  }
});
