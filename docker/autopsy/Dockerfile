# syntax=docker/dockerfile:1.7

ARG KASM_TAG=1.19.0
ARG KASM_AMD64_DIGEST=sha256:edf1c90f3bf5b8a2c9c0141b237f5b1913771c587d2e5b64d8da8d778245e01d
FROM kasmweb/ubuntu-noble-desktop:${KASM_TAG}@${KASM_AMD64_DIGEST}

USER root

ARG AUTOPSY_VERSION=4.23.1
ARG AUTOPSY_SHA256=b58cd4c04f42f49823488f05f6a5b43ada470ff7343c2d71dd2e154114d09eae
ARG TSK_VERSION=4.15.0
ARG TSK_SHA256=3a8c1e7d18a9b81f3e5e8aa78313974aceaafc6e051d636bc92cd7168286eca9

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/kasm-default-profile \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    STARTUPDIR=/dockerstartup \
    AUTOPSY_HOME=/opt/autopsy-current \
    TSK_JAVA_LIB_PATH=/usr/local/share/java \
    LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# Autopsy's official Linux prerequisites plus the build tools needed for the
# Sleuth Kit Java/JNI bindings. The downloads are pinned and checksum-verified.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ant \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        curl \
        gstreamer1.0-alsa \
        gstreamer1.0-gl \
        gstreamer1.0-gtk3 \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-pulseaudio \
        gstreamer1.0-qt5 \
        gstreamer1.0-tools \
        gstreamer1.0-x \
        libafflib-dev \
        libbfio-dev \
        libde265-dev \
        libewf-dev \
        libheif-dev \
        libpq-dev \
        libsqlite3-dev \
        libtool \
        libvhdi-dev \
        libvmdk-dev \
        libvslvm-dev \
        openjdk-17-jdk \
        pkg-config \
        testdisk \
        unzip \
        zip \
        zlib1g-dev \
    && curl --fail --location --retry 5 --retry-delay 3 \
        --output /tmp/sleuthkit.tar.gz \
        "https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-${TSK_VERSION}/sleuthkit-${TSK_VERSION}.tar.gz" \
    && printf '%s  %s\n' "${TSK_SHA256}" /tmp/sleuthkit.tar.gz | sha256sum --check --strict \
    && mkdir -p /tmp/sleuthkit-src \
    && tar --extract --gzip --file /tmp/sleuthkit.tar.gz --strip-components=1 --directory /tmp/sleuthkit-src \
    && cd /tmp/sleuthkit-src \
    && if [ ! -x ./configure ]; then ./bootstrap; fi \
    && ./configure --enable-java \
    && make -j"$(nproc)" \
    && make install \
    && ldconfig \
    && test -f "/usr/local/share/java/sleuthkit-${TSK_VERSION}.jar" \
    && curl --fail --location --retry 5 --retry-delay 5 \
        --output /tmp/autopsy.zip \
        "https://github.com/sleuthkit/autopsy/releases/download/autopsy-${AUTOPSY_VERSION}/autopsy-${AUTOPSY_VERSION}.zip" \
    && printf '%s  %s\n' "${AUTOPSY_SHA256}" /tmp/autopsy.zip | sha256sum --check --strict \
    && mkdir -p /opt/autopsy \
    && unzip -q /tmp/autopsy.zip -d /opt/autopsy \
    && AUTOPSY_SETUP="$(find /opt/autopsy -maxdepth 2 -type f -name unix_setup.sh -print -quit)" \
    && test -n "${AUTOPSY_SETUP}" \
    && AUTOPSY_EXTRACTED_DIR="$(dirname "${AUTOPSY_SETUP}")" \
    && cd "${AUTOPSY_EXTRACTED_DIR}" \
    && chmod 0755 unix_setup.sh \
    && ./unix_setup.sh -j "${JAVA_HOME}" -n autopsy \
    && ln -s "${AUTOPSY_EXTRACTED_DIR}" "${AUTOPSY_HOME}" \
    && test -x "${AUTOPSY_HOME}/bin/autopsy" \
    && rm -rf /tmp/autopsy.zip /tmp/sleuthkit.tar.gz /tmp/sleuthkit-src /var/lib/apt/lists/* \
    && mkdir -p /cases /evidence /home/kasm-user/.autopsy /home/kasm-user/.cache/autopsy \
    && chown -R 1000:0 /cases /home/kasm-user/.autopsy /home/kasm-user/.cache/autopsy /opt/autopsy \
    && chmod 0770 /cases \
    && chown root:root /evidence \
    && chmod 0555 /evidence

COPY --chown=1000:0 start-autopsy.sh /usr/local/bin/start-kasm-autopsy
COPY --chown=1000:0 custom_startup.sh ${STARTUPDIR}/custom_startup.sh

RUN chmod 0755 /usr/local/bin/start-kasm-autopsy ${STARTUPDIR}/custom_startup.sh

ENV HOME=/home/kasm-user

WORKDIR /cases
USER 1000

