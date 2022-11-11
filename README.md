# Integrated Nx Monorepo with multiple Remix apps

> For any questions, feedback, swag, or contributions, reach out to [Jacob Paris](https://twitter.com/intent/follow?screen_name=jacobmparis)

This is an example of running multiple Remix apps in an Nx integrated monorepo, each with their own Dockerfile and deployed independently based on affected changes.

You can run this locally, or in an automated cloud development environment via Gitpod

- .env files for each Remix app can be persisted
- Images from all docker compose files in the repo are pre-pulled before the workspace starts
- Fly.io and Nx CLIs are pre-installed

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/jacobparis/remix-nx-fly)

## Adding an existing Remix app

Clone your source repository into a folder inside `/apps`

Delete the `.git` directory in this newly cloned folder to detach it from its source repository

## Managing dependencies

The main difference between a standalone Remix app and an app in an integrated Nx monorepo is that in the monorepo, all apps share the same modules. There is one `package.json` at the top level that contains all the modules for all applications.

The dependencies in the application level `package.json` are fully automated by the `"deps:json"` target in the `project.json`. It looks at every imported module in `deps.ts` and adds it to the `package.json` with the correct version.

Every `devDependency` for every app is copied into each app's `package.json`. These do not make it in to the production build, but are sometimes necessary for building.

## Prisma

The Prisma client installs by default in the root monorepo's modules. The `prisma/schema.prisma` file has been explicitly set to use the app's `node_modules` as an output directory.

As a consequence, the Dockerfile has also been updated to copy the prisma directory as `ADD prisma ./prisma` instead of `ADD prisma .`, so that the relative path still works.

## CI

Nx has a tool called `nx affected` that runs target scripts for only the apps that have been affected by changes (for example, in a PR). To take advantage of this, Each task that runs in CI should be behind an Nx target.

Commits directly to `main` (including merging branches into `main`) are automatically the latest commit at the time that CI runs, so affected changes are detected by comparing against the second latest commit to `main`.

Commits to branches can be compared directly against the latest commit to `main`

In GitHub Actions, this can be automated as a one-liner in the following manner. Note `--target=lint` as the task that will run for each affected app

```sh
npx nx affected --base=$([[ ${{ github.ref == 'refs/heads/main'}} ]] && echo "origin/main~1" || echo "origin/main") --head=HEAD --target=lint --parallel=3
```

The `@nx-tools/nx-docker:build` that is used to build docker images for each app can be configured via dynamic environment variables. A variable named `INPUT_INDIE_STACK_TAGS` will set the `tags` property for the `indie-stack` app. Similarly, `INPUT_BLUES_STACK_TAGS` will do the same for the `blues-stack`.

## Troubleshooting

- If any devDependencies are not available in the built image, a quick fix can be to call them with `npx`, which will install them if not already present.

## Updating .env files

If you are developing locally, make changes to each app's .env file and just leave it on the file system like normal. They are protected by .gitignore and will not be committed.

If you are developing in Gitpod, make your changes to each .env file and then run `nx run-many --target=save-env --all` to save them as the new default .env files for new workspaces.
