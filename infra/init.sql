-- Этот файл инициализирует минимальные объекты базы данных для локального MVP.
-- Роль файла: гарантировать предсказуемый старт Postgres после docker compose up.
-- Основные функции: создание служебной схемы и таблицы метаданных окружения.
-- Связи: автоматически исполняется контейнером postgres из infra/docker-compose.yml.
-- Важно при изменении: SQL должен быть идемпотентным и безопасным для повторного запуска.

-- Создаём отдельную схему для инфраструктурных метаданных,
-- чтобы не смешивать технические таблицы с будущими доменными таблицами приложения.
CREATE SCHEMA IF NOT EXISTS platform;

-- Таблица хранит простые технические ключи/значения о запуске окружения.
-- Выбор формата key-value упрощает расширение без частых миграций на раннем этапе MVP.
CREATE TABLE IF NOT EXISTS platform.environment_meta (
  key text PRIMARY KEY,
  value text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Базовая запись помогает быстро проверить, что init.sql действительно применился.
INSERT INTO platform.environment_meta (key, value)
VALUES ('bootstrap', 'ok')
ON CONFLICT (key) DO NOTHING;

-- Таблица analytics_events хранит продуктовые и технические события MVP.
-- Поля оставлены универсальными, чтобы быстро добавлять новые event types без миграций.
CREATE TABLE IF NOT EXISTS platform.analytics_events (
  id bigserial PRIMARY KEY,
  event_name text NOT NULL,
  user_id text NULL,
  session_id text NULL,
  source text NOT NULL DEFAULT 'backend',
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Индекс по времени нужен для dashboard последних 7 дней.
CREATE INDEX IF NOT EXISTS idx_analytics_events_created_at ON platform.analytics_events (created_at DESC);

-- Индекс по event_name упрощает выборку по типам событий (например, match_create).
CREATE INDEX IF NOT EXISTS idx_analytics_events_event_name ON platform.analytics_events (event_name);
