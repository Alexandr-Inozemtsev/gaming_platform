FROM node:20-alpine

WORKDIR /app
COPY services/rules-engine ./services/rules-engine

EXPOSE 3003
CMD ["node", "services/rules-engine/src/runtime.mjs"]
