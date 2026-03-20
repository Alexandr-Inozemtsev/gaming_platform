FROM node:20-alpine

WORKDIR /app
COPY services/admin ./services/admin

EXPOSE 3002
CMD ["node", "services/admin/src/runtime.mjs"]
