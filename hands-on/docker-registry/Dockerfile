FROM node:14-alpine

WORKDIR /app

COPY app/package*.json ./

RUN npm install --production

COPY app/ ./

EXPOSE 3000

CMD ["node", "index.js"]
