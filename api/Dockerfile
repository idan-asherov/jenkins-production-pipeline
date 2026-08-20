FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ARG BUILD_NUMBER=local
ARG COMMIT_HASH=unknown
ENV BUILD_NUMBER=${BUILD_NUMBER}
ENV COMMIT_HASH=${COMMIT_HASH}
EXPOSE 3000
CMD [ "npm", "start" ]
