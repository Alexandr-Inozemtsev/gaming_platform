/**
 * Назначение файла: предоставить CLI-команду генератора game definitions, симуляций и тестовых фикстур.
 * Роль в проекте: запускаться из npm run gen:game и сохранять результаты в заданную папку out.
 * Основные функции: разбор аргументов, генерация definition JSON, запуск simulateDefinition, запись fixture-файла.
 * Связи с другими файлами: использует tools/generator/core.mjs и выводит файлы для tests в services/rules-engine/fixtures/.
 * Важно при изменении: сохранять дружелюбный CLI output и обратную совместимость параметров --template/--out/--n.
 */

import fs from 'node:fs';
import path from 'node:path';
import { buildDefinitionByTemplate, buildFixtureFromSimulations, simulateDefinition } from './core.mjs';

const argv = process.argv.slice(2);
const readArg = (name, fallback = null) => {
  const i = argv.indexOf(name);
  if (i === -1) return fallback;
  return argv[i + 1] ?? fallback;
};

const template = readArg('--template', 'tile');
const outDirRaw = readArg('--out', 'services/rules-engine/fixtures/');
const outDir = path.isAbsolute(outDirRaw) ? outDirRaw : path.join(process.cwd(), outDirRaw);
const rounds = Number(readArg('--n', process.env.N_SIM ?? '100'));

if (!Number.isInteger(rounds) || rounds < 1 || rounds > 5000) {
  throw new Error('INVALID_N_SIM: допустимый диапазон 1..5000');
}

const definition = buildDefinitionByTemplate(template);
const simulations = simulateDefinition(definition, rounds);
const fixture = buildFixtureFromSimulations(definition, simulations);

fs.mkdirSync(outDir, { recursive: true });
const definitionPath = path.join(outDir, `${definition.id}.json`);
const fixturePath = path.join(outDir, `${definition.id}.fixture.json`);

fs.writeFileSync(definitionPath, JSON.stringify(definition, null, 2));
fs.writeFileSync(fixturePath, JSON.stringify(fixture, null, 2));

console.log(`Generated: ${path.basename(definitionPath)} OK`);
console.log(`Generated: ${path.basename(fixturePath)} OK`);
console.log(`Simulations: ${rounds} finished=${fixture.stats.finished}/${fixture.stats.total}`);
