CREATE TABLE IF NOT EXISTS campaigns (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  event_name TEXT NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rewards (
  id TEXT PRIMARY KEY,
  campaign_id TEXT,
  user_id TEXT NOT NULL,
  reward_type TEXT NOT NULL,
  reward_value TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT rewards_campaign_fk FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS leaderboards (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  score INTEGER NOT NULL DEFAULT 0,
  period TEXT NOT NULL DEFAULT 'all-time',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS levels (
  id TEXT PRIMARY KEY,
  campaign_id TEXT NOT NULL,
  config_json JSONB NOT NULL,
  level_index INTEGER NOT NULL,
  CONSTRAINT levels_campaign_fk FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
  CONSTRAINT levels_campaign_idx_unique UNIQUE (campaign_id, level_index)
);

ALTER TABLE matches ADD COLUMN IF NOT EXISTS campaign_id TEXT;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS level INTEGER NOT NULL DEFAULT 1;
ALTER TABLE matches ADD CONSTRAINT matches_campaign_fk FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS legacy_games (
  id TEXT PRIMARY KEY,
  config_json JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS legacy_state (
  id TEXT PRIMARY KEY,
  match_id TEXT UNIQUE NOT NULL,
  turn_data JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS coop_sessions (
  id TEXT PRIMARY KEY,
  match_id TEXT,
  config_json JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
