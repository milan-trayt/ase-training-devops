FROM node:20.17.0-alpine3.19

WORKDIR /home/app

ENV NODE_OPTIONS=--max_old_space_size=4096

COPY ["./package.json", "./package-lock.json", "./"]

RUN npm install

COPY . .

ARG REGISTRY_URI
ARG SECRET_PREFIX
ARG AWS_REGION="us-west-2"
ARG DATABASE_URL

ENV NODE_ENV=production
ENV SECRET_PREFIX=${SECRET_PREFIX}
ENV AWS_REGION=${AWS_REGION}
ENV DATABASE_URL=${DATABASE_URL}

RUN apk add --no-cache bash
RUN apk add --no-cache aws-cli

EXPOSE 3000
CMD ["/bin/bash","entrypoint.sh"]