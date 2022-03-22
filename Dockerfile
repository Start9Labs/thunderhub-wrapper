# ---------------
# Install Dependencies
# ---------------
FROM arm64v8/node:14.15-alpine as deps

WORKDIR /app

# Install dependencies neccesary for node-gyp on node alpine
RUN apk add --update --no-cache \
    libc6-compat \
    python3 \
    make \
    g++


# Install app dependencies
COPY ./thunderhub/package.json ./thunderhub/package-lock.json ./
RUN npm ci

FROM arm64v8/golang:1.17.7-alpine3.15 as yqbuild

ENV GO111MODULE=on
RUN go install github.com/mikefarah/yq/v4@v4.20.2

# ---------------
# Build App
# ---------------
FROM deps as build

WORKDIR /app

# Set env variables
ARG BASE_PATH=""
ENV BASE_PATH=${BASE_PATH}
ARG NODE_ENV="production"
ENV NODE_ENV=${NODE_ENV}
ENV NEXT_TELEMETRY_DISABLED=1

# Build the NextJS application
COPY ./thunderhub .
RUN npm run build

# Remove non production necessary modules
RUN npm prune --production

# ---------------
# Release App
# ---------------
FROM arm64v8/node:14.15-alpine

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories
RUN apk add --update --no-cache yq bash coreutils curl

WORKDIR /app

# Set env variables
ARG BASE_PATH=""
ENV BASE_PATH=${BASE_PATH}
ARG NODE_ENV="production"
ENV NODE_ENV=${NODE_ENV}
ENV NEXT_TELEMETRY_DISABLED=1

COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules/ ./node_modules 

# Copy NextJS files
COPY --from=build /app/src/client/public ./src/client/public
COPY --from=build /app/src/client/next.config.js ./src/client/
COPY --from=build /app/src/client/.next/ ./src/client/.next

# Copy NestJS files
COPY --from=build /app/dist/ ./dist

# Copy yq binary
COPY --from=yqbuild /go/bin/yq /usr/bin/yq

EXPOSE 3000 

COPY ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod +x /usr/local/bin/docker_entrypoint.sh
ADD ./check-web.sh /usr/local/bin/check-web.sh
RUN chmod +x /usr/local/bin/check-web.sh

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
