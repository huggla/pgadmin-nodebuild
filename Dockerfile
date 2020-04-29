FROM node:alpine

ARG PGADMIN_VERSION="4.20"

RUN apk add --no-cache autoconf automake bash g++ libc6-compat libjpeg-turbo-dev libpng-dev make nasm git zlib-dev \
 && wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v$PGADMIN_VERSION/source/pgadmin4-$PGADMIN_VERSION.tar.gz \
 && tar -xpf pgadmin4-$PGADMIN_VERSION.tar.gz \
 && mv pgadmin4-$PGADMIN_VERSION/web pgadmin4 \
 && rm -rf pgadmin4-$PGADMIN_VERSION pgadmin4/*.log pgadmin4/config_*.py pgadmin4/node_modules pgadmin4/regression \
 && find pgadmin4 -type d -name tests | xargs rm -rf \
 && find pgadmin4 -type f -name .DS_Store -delete \
 && cd pgadmin4 \
 && npm install \
 && npm audit fix \
 && rm -f yarn.lock \
 && yarn import \
 && yarn audit \
 && yarn audit --groups dependencies \
 && rm -f package-lock.json \
 && yarn run bundle \
 && rm -rf node_modules yarn.lock package.json .[^.]* babel.cfg webpack.* karma.conf.js pgadmin/static/js/generated/.cache

