# New workspace

This repository is fully automated
- Ephemeral cloud development environment
- .env files for each Remix app can be persisted
- Images from all docker compose files in the repo are pre-pulled before the workspace starts
- Fly.io and Nx CLIs are pre-installed

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/jacobparis/remix-nx-fly)

## Updating .env files

If you are developing locally, make changes to each app's .env file and just leave it on the file system like normal. They are protected by .gitignore and will not be committed. 

If you are developing in Gitpod, make your changes to each .env file and then run `nx run-many --target=save-env --all` to save them as the new default .env files for new workspaces.

