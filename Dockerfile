FROM node:16.16.0-buster

ARG USERNAME=kibana

RUN groupadd -r kibana && useradd --no-log-init -r -g kibana $USERNAME
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

WORKDIR /home/kibana
# RUN sudo npm install --force --location=global yarn

RUN echo 'export PATH="$(yarn global bin):$PATH"' >> ~/.bash_profile

RUN /bin/bash -c 'source ~/.bash_profile'

COPY *.json *.ts .*rc *.bazel .bazel* ./
COPY yarn.lock .node-version preinstall_check.js ./
COPY src ./src
COPY x-pack ./x-pack
COPY packages ./packages
COPY scripts ./scripts
COPY kbn_pm ./kbn_pm
COPY examples ./examples
COPY typings ./typings

RUN sudo yarn kbn bootstrap --force-install

COPY ./ ./

CMD ["sudo", "yarn", "start"]

# yarn.lock .node-version preinstall_check.js
# WORKSPACE.bazel .yarnrc tsconfig.json package.json (*.json) (.*rc) (.bazel*) (*.bazel) (*.ts)
# src x-pack packages scripts kbn_pm examples
