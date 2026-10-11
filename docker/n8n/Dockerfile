# syntax=docker/dockerfile:1.7

ARG NODE_TAG=24-bookworm-slim
FROM node:${NODE_TAG} AS n8n-runtime

ARG N8N_VERSION=2.42.6

RUN npm install --global --omit=dev "n8n@${N8N_VERSION}" \
    && test "$(n8n --version)" = "${N8N_VERSION}" \
    && npm cache clean --force

ARG KASM_TAG=1.19.0-rolling-weekly
FROM kasmweb/chrome:${KASM_TAG}

USER root

ENV HOME=/home/kasm-default-profile \
    STARTUPDIR=/dockerstartup

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl libstdc++6 openssl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=n8n-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=n8n-runtime /usr/local/bin/n8n /usr/local/bin/n8n
COPY --from=n8n-runtime /usr/local/lib/node_modules/n8n /usr/local/lib/node_modules/n8n

COPY --chown=1000:0 start-n8n.sh /usr/local/bin/start-kasm-n8n
COPY --chown=1000:0 custom_startup.sh ${STARTUPDIR}/custom_startup.sh

RUN chmod 0755 /usr/local/bin/start-kasm-n8n ${STARTUPDIR}/custom_startup.sh \
    && mkdir -p /home/kasm-user/.n8n \
    && chown -R 1000:0 /home/kasm-user/.n8n \
    && chmod 0700 /home/kasm-user/.n8n

ENV HOME=/home/kasm-user
WORKDIR /home/kasm-user

USER 1000
