/**
 * Назначение файла: реализовать минимальный локальный линтинг backend-сервисов без внешних зависимостей.
 * Роль в проекте: обеспечить стабильную проверку в CI даже в средах с ограниченным доступом к npm registry.
 * Основные функции: проверять наличие запрещённых конструкций и обязательных каталогов src/test.
 * Связи: вызывается из package.json через скрипт `npm run lint` и используется в .github/workflows/ci.yml.
 * Важно при изменении: сохранять детерминированность и быстрый запуск, чтобы линт оставался надёжным gate в CI.
 */

import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

/**
 * Явно задаём список сервисов, чтобы проверка была предсказуемой
 * и не зависела от случайных файлов в директории services.
 */
const services = ['api', 'realtime', 'rules-engine', 'admin'];

/**
 * Запрещаем обёртки import в try/catch согласно правилам AGENTS.md,
 * потому что такие конструкции скрывают ошибки загрузки модулей.
 */
const forbiddenPatterns = [
  {
    name: 'try/catch вокруг import',
    regexp: /try\s*\{[^]*?import\s+/m
  },
  {
    name: 'debugger в исходниках',
    regexp: /\bdebugger\b/m
  }
];

let hasError = false;

for (const service of services) {
  const serviceDir = join(process.cwd(), 'services', service);
  const srcDir = join(serviceDir, 'src');
  const testDir = join(serviceDir, 'test');

  if (!existsSync(srcDir) || !existsSync(testDir)) {
    console.error(`[lint] Сервис ${service}: отсутствует src или test директория.`);
    hasError = true;
    continue;
  }

  const entryFile = join(srcDir, 'index.ts');
  if (!existsSync(entryFile)) {
    console.error(`[lint] Сервис ${service}: отсутствует обязательный файл src/index.ts.`);
    hasError = true;
    continue;
  }

  const source = readFileSync(entryFile, 'utf8');
  for (const pattern of forbiddenPatterns) {
    if (pattern.regexp.test(source)) {
      console.error(`[lint] Сервис ${service}: найдено нарушение "${pattern.name}" в src/index.ts.`);
      hasError = true;
    }
  }
}

if (hasError) {
  process.exit(1);
}

console.log('[lint] Проверки сервисов пройдены успешно.');
