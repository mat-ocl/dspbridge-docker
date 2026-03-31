FROM debian:trixie

LABEL org.opencontainers.image.source=https://github.com/mat-ocl/dspbridge-docker

# VERSION is overridden by the 'build-args' in the GitHub Action - this is a fallback
ARG VERSION="2.1.4"
ARG BRIDGE="TheUsualSuspects-DSPBridgeServer-${VERSION}-Linux_x86_64.deb"
ARG BASEURL="https://github.com/dsp56300/gearmulator/releases/download/${VERSION}/"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ADD "${BASEURL}${BRIDGE}" /tmp/"${BRIDGE}"

RUN dpkg -i /tmp/"${BRIDGE}" || apt-get install -f -y && \
    rm /tmp/"${BRIDGE}"

ENTRYPOINT ["/usr/local/dsp56300EmuServer"]