FROM gitpod/workspace-full

# Custom node version
# https://www.gitpod.io/docs/introduction/languages/javascript#node-versions
RUN bash -c 'VERSION="18.12.0" \
    && source $HOME/.nvm/nvm.sh && nvm install $VERSION \
    && nvm use $VERSION && nvm alias default $VERSION'

RUN echo "nvm use default &>/dev/null" >> ~/.bashrc.d/51-nvm-fix

# Custom npm version
RUN npm install -g npm@9.1.1

# Install Fly
RUN curl -L https://fly.io/install.sh | sh
ENV FLYCTL_INSTALL="/home/gitpod/.fly"
ENV PATH="$FLYCTL_INSTALL/bin:$PATH"

# Install NX CLI
RUN npm i nx -g
ENV NX_DAEMON=false
