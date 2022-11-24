# base node image
FROM node:16-bullseye-slim as base

# set for base and all layer that inherit from it
ENV NODE_ENV production

# Install openssl for Prisma
RUN apt-get update && apt-get install -y openssl

# Install all node_modules, including dev dependencies
FROM base as deps

WORKDIR /myapp

ADD package.json .npmrc ./apps/blues-stack/
RUN npm --prefix ./apps/blues-stack/ install --production=false

# Setup production node_modules
FROM base as production-deps

WORKDIR /myapp

COPY --from=deps /myapp/apps/blues-stack/node_modules /myapp/apps/blues-stack/node_modules
ADD package.json .npmrc ./apps/blues-stack/

RUN npm --prefix ./apps/blues-stack/ prune --production

# Build the app
FROM base as build

WORKDIR /myapp

COPY --from=deps /myapp/apps/blues-stack/node_modules /myapp/apps/blues-stack/node_modules

ADD temp/tsconfig.base.json .
ADD temp/libs ./libs/
ADD prisma ./apps/blues-stack/prisma
RUN npx --prefix ./apps/blues-stack/ prisma generate

ADD . ./apps/blues-stack

RUN npm --prefix ./apps/blues-stack/ run build

# Finally, build the production image with minimal footprint
FROM base

WORKDIR /myapp

COPY --from=production-deps /myapp/apps/blues-stack/node_modules /myapp/apps/blues-stack/node_modules
COPY --from=build /myapp/apps/blues-stack/node_modules/.prisma /myapp/apps/blues-stack/node_modules/.prisma

COPY --from=build /myapp/apps/blues-stack/build /myapp/apps/blues-stack/build
COPY --from=build /myapp/apps/blues-stack/public /myapp/apps/blues-stack/public
ADD . ./apps/blues-stack

CMD ["npm", "start"]
