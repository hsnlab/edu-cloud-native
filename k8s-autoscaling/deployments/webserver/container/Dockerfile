FROM node:lts
EXPOSE 8080
COPY server.js .
COPY package.json .
RUN npm i
CMD node server.js