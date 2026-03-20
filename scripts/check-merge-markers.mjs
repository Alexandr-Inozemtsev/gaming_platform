// Назначение: остановить сборку при попадании merge conflict markers в кодовую базу.
import { spawnSync } from 'node:child_process';

const rg = spawnSync('rg', ['-n', '^(<<<<<<<|=======|>>>>>>>)', '--glob', '!package-lock.json', '--glob', '!*pubspec.lock*', '.'], {
  cwd: process.cwd(),
  encoding: 'utf8'
});

if (rg.status === 1) {
  console.log('[merge-check] Conflict markers не найдены.');
  process.exit(0);
}

if (rg.status !== 0 && rg.status !== 1) {
  console.error('[merge-check] Не удалось выполнить rg:', rg.stderr || rg.stdout);
  process.exit(2);
}

const lines = rg.stdout.trim();
if (lines.length === 0) {
  console.log('[merge-check] Conflict markers не найдены.');
  process.exit(0);
}

console.error('[merge-check] Найдены conflict markers:');
console.error(lines);
process.exit(1);
