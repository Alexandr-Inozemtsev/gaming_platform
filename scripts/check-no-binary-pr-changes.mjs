import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);

const blockedPattern = /\.(png|jpe?g|webp|gif|bmp|ico|pdf|mp4|mov|avi|ttf|otf|woff2?)$/i;

function parseNumstat(raw) {
  return raw
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [added, removed, ...pathParts] = line.split('\t');
      return {
        added,
        removed,
        path: pathParts.join('\t'),
      };
    });
}

async function getStagedNumstat() {
  const { stdout } = await execFileAsync('git', ['diff', '--cached', '--numstat']);
  return parseNumstat(stdout);
}

const entries = await getStagedNumstat();
const violations = entries.filter((entry) => {
  const isBinaryDiff = entry.added === '-' || entry.removed === '-';
  const looksBinaryByExtension = blockedPattern.test(entry.path);
  return isBinaryDiff || looksBinaryByExtension;
});

if (violations.length > 0) {
  console.error('Binary-like staged changes are not allowed for Codex PR.');
  console.error('Unstage/remove these files and use external asset delivery (CDN/release artifacts):');
  for (const violation of violations) {
    console.error(`- ${violation.path}`);
  }
  process.exit(1);
}

console.log('No staged binary-like changes detected.');
