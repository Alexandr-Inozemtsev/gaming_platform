FROM node:20-alpine

WORKDIR /app
COPY services/realtime ./services/realtime

EXPOSE 3001
CMD ["node", "services/realtime/src/runtime.mjs"]
