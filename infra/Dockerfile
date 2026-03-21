# Multi-target Dockerfile for P2 services.
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
COPY services ./services

FROM base AS api
EXPOSE 3000
CMD ["node", "services/api/src/runtime.mjs"]

FROM base AS matches
EXPOSE 3101
ENV API_PORT=3101
CMD ["node", "services/api/src/runtime.mjs"]

FROM base AS campaigns
EXPOSE 3102
ENV API_PORT=3102
CMD ["node", "services/api/src/runtime.mjs"]

FROM base AS analytics
EXPOSE 3103
ENV API_PORT=3103
CMD ["node", "services/api/src/runtime.mjs"]

FROM base AS web-socket
EXPOSE 3001
CMD ["node", "services/realtime/src/runtime.mjs"]
