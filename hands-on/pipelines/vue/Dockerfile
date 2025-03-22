FROM node:lts-alpine

# install simple http server for serving static content
RUN npm install -g http-server

# set working directory
WORKDIR /app

# copy both 'package.json' and 'yarn.lock' (if available)
COPY app/package*.json app/yarn*.lock ./

# install project dependencies
RUN yarn install

# copy project files and folders to the current working directory (i.e. 'app' folder)
COPY app/ ./

# build app for production with static generation
RUN yarn generate

# expose the correct port
EXPOSE 8080

# use -p flag to specify port 8080
CMD [ "http-server", "/app/.output/public", "-p", "8080" ]