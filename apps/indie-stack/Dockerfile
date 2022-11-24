# base node image
FROM node:16-bullseye-slim as base

# set for base and all layer that inherit from it
ENV NODE_ENV production

# Install openssl for Prisma
RUN apt-get update && apt-get install -y openssl sqlite3

# Install all node_modules, including dev dependencies
FROM base as deps

WORKDIR /myapp/apps/indie-stack

ADD package.json .npmrc ./
RUN npm install --production=false

# Setup production node_modules
FROM base as production-deps

WORKDIR /myapp/apps/indie-stack

COPY --from=deps /myapp/apps/indie-stack/node_modules /myapp/apps/indie-stack/node_modules
ADD package.json .npmrc ./
RUN npm prune --production

# Build the app
FROM base as build

WORKDIR /myapp

ADD temp/tsconfig.base.json .
ADD temp/libs ./libs/

WORKDIR /myapp/apps/indie-stack

COPY --from=deps /myapp/apps/indie-stack/node_modules /myapp/apps/indie-stack/node_modules

ADD prisma ./prisma
RUN npx prisma generate

ADD . .
RUN npm run build

# Finally, build the production image with minimal footprint
FROM base

ENV DATABASE_URL=file:/data/sqlite.db
ENV PORT="8080"
ENV NODE_ENV="production"

# add shortcut for connecting to database CLI
RUN echo "#!/bin/sh\nset -x\nsqlite3 \$DATABASE_URL" > /usr/local/bin/database-cli && chmod +x /usr/local/bin/database-cli

WORKDIR /myapp/apps/indie-stack

COPY --from=production-deps /myapp/apps/indie-stack/node_modules /myapp/apps/indie-stack/node_modules
COPY --from=build /myapp/apps/indie-stack/node_modules/.prisma /myapp/apps/indie-stack/node_modules/.prisma

COPY --from=build /myapp/apps/indie-stack/build /myapp/apps/indie-stack/build
COPY --from=build /myapp/apps/indie-stack/public /myapp/apps/indie-stack/public
COPY --from=build /myapp/apps/indie-stack/package.json /myapp/apps/indie-stack/package.json
COPY --from=build /myapp/apps/indie-stack/start.sh /myapp/apps/indie-stack/start.sh
COPY --from=build /myapp/apps/indie-stack/prisma /myapp/apps/indie-stack/prisma

ENTRYPOINT [ "./start.sh" ]
