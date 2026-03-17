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
