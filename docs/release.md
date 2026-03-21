# Release checklist P2

## Repo -> cluster
1. `npm install`
2. `npm run lint`
3. `npm test`
4. `ENV=prod DB_MIGRATE=true scripts/prod-up.sh`
5. `scripts/smoke-p2.sh`

## Smoke checks
- login/register
- campaign create + start
- complete level and verify `/leaderboard`
- analytics events `level_complete` / `campaign_finished`

## Mobile build commands
- `cd apps/mobile && flutter build apk`
- `cd apps/mobile && flutter build ipa`
