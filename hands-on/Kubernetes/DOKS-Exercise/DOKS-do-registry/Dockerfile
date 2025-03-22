FROM node:14-alpine

WORKDIR /app

COPY app.js package.json ./

RUN npm install

EXPOSE 3000

CMD ["node", "app.js"]
