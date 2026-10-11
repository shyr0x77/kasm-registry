# syntax=docker/dockerfile:1.7

ARG KASM_TAG=1.19.0-rolling-weekly
FROM kasmweb/chrome:${KASM_TAG}

USER root

ARG VELOCIRAPTOR_VERSION=0.77.3
ARG VELOCIRAPTOR_SHA256=b4699d7ecfd5c0d656d86379e41f0eb34b0f12c3cb45398f1e747f10844d7930

ENV HOME=/home/kasm-default-profile \
    STARTUPDIR=/dockerstartup

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl --fail --location --retry 3 \
      --output /tmp/velociraptor.gz \
      "https://github.com/Velocidex/velociraptor/releases/download/v${VELOCIRAPTOR_VERSION}/velociraptor-v${VELOCIRAPTOR_VERSION}-linux-amd64-musl.gz" \
    && printf '%s  %s\n' "${VELOCIRAPTOR_SHA256}" /tmp/velociraptor.gz | sha256sum --check - \
    && gzip --decompress --stdout /tmp/velociraptor.gz > /usr/local/bin/velociraptor \
    && chmod 0755 /usr/local/bin/velociraptor \
    && rm /tmp/velociraptor.gz

COPY --chown=1000:0 start-velociraptor.sh /usr/local/bin/start-kasm-velociraptor
COPY --chown=1000:0 custom_startup.sh ${STARTUPDIR}/custom_startup.sh

RUN chmod 0755 /usr/local/bin/start-kasm-velociraptor ${STARTUPDIR}/custom_startup.sh

ENV HOME=/home/kasm-user
WORKDIR /home/kasm-user

USER 1000
