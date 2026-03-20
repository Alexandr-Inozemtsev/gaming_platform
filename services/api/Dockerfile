# Назначение файла: собрать контейнер API-сервиса для локального prod-like запуска и smoke-проверок.
# Роль в проекте: предоставить исполняемую среду Node.js для services/api вместе с локальным импортом rules-engine.
# Основные функции: копирование исходников API и rules-engine в общий /app, открытие порта API и запуск runtime entrypoint.
# Связи с другими файлами: используется docker-compose.prod.yml и зависит от imports в services/api/src/app.mjs.
# Важно при изменении: сохранять наличие services/rules-engine в образе, иначе локальный импорт index.mjs вызовет ERR_MODULE_NOT_FOUND.
FROM node:20-alpine

WORKDIR /app
COPY services/api ./services/api
COPY services/rules-engine ./services/rules-engine

EXPOSE 3000
CMD ["node", "services/api/src/runtime.mjs"]
