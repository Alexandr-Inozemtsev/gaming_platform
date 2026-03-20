FROM node:20-alpine

WORKDIR /app
COPY services/api ./services/api

EXPOSE 3000
CMD ["node", "services/api/src/runtime.mjs"]
