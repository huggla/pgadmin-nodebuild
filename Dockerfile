########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2018, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
#########################################################################

#########################################################################
# Create a Node container which will be used to build the JS components
# and clean up the web/ source code
#########################################################################

FROM node:10-alpine AS app-builder

RUN apk add --no-cache \
    autoconf \
    automake \
    bash \
    g++ \
    libc6-compat \
    libjpeg-turbo-dev \
    libpng-dev \
    make \
    nasm \
    git \
    zlib-dev

# Create the /pgadmin4 directory and copy the source into it. Explicitly
# remove the node_modules directory as we'll recreate a clean version, as well
# as various other files we don't want
RUN wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v4.20/source/pgadmin4-4.20.tar.gz \
&& tar -xvpf pgadmin4-4.20.tar.gz \
&& mv pgadmin4-4.20 pgadmin4 \
&& rm -rf /pgadmin4/web/*.log \
           /pgadmin4/web/config_*.py \
           /pgadmin4/web/node_modules \
           /pgadmin4/web/regression \
           `find /pgadmin4/web -type d -name tests` \
           `find /pgadmin4/web -type f -name .DS_Store`

WORKDIR /pgadmin4/web

# Build the JS vendor code in the app-builder, and then remove the vendor source.
RUN npm install && \
	npm audit fix && \
	rm -f yarn.lock && \
	yarn import && \
# Commented the below line to avoid vulnerability in decompress package and
# audit only dependencies folder. Refer https://www.npmjs.com/advisories/1217.
# Pull request is already been send https://github.com/kevva/decompress/pull/73,
# once fixed we will uncomment it.
#	yarn audit && \
	yarn audit --groups dependencies && \
	rm -f package-lock.json && \
    yarn run bundle && \
    rm -rf node_modules \
           yarn.lock \
           package.json \
           .[^.]* \
           babel.cfg \
           webpack.* \
           karma.conf.js \
           ./pgadmin/static/js/generated/.cache

