# syntax=docker/dockerfile:1

FROM debian:bookworm-slim AS fetch
ARG TARGETARCH
ARG ANKI_VERSION=26.09.3
ARG ANKI_SHA256_AMD64=d70e01971a7aa190b189927573ee643f2525ff840eafaecc7a8f8cde505650b3
ARG ANKI_SHA256_ARM64=0b586efdb0e3582bee3b9d08b9fa57df681fb97a8066d76a6743e1bc3fc331eb
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl zstd \
    && rm -rf /var/lib/apt/lists/* \
    && case "${TARGETARCH}" in \
        amd64) ANKI_ARCH=x86_64; ANKI_SHA256=${ANKI_SHA256_AMD64} ;; \
        arm64) ANKI_ARCH=aarch64; ANKI_SHA256=${ANKI_SHA256_ARM64} ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL -o /tmp/anki.tar.zst \
        "https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-${ANKI_VERSION}-linux-${ANKI_ARCH}.tar.zst" \
    && echo "${ANKI_SHA256}  /tmp/anki.tar.zst" | sha256sum -c - \
    && mkdir /anki \
    && tar --zstd -xf /tmp/anki.tar.zst -C /anki --strip-components=1

FROM debian:bookworm-slim
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/share/keyrings/xpra.asc https://xpra.org/xpra.asc \
    && wget -O /etc/apt/sources.list.d/xpra.sources \
        https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/bookworm/xpra.sources

RUN apt-get update && apt-get install -y --no-install-recommends \
        gocryptfs fuse3 xvfb xpra xpra-x11 xpra-html5 libjs-jquery libjs-jquery-ui \
        python3-lz4 python3-paramiko python3-uinput xauth dbus-x11 python3-dbus \
        python3-avahi python3-pil python3-pyinotify python3-xdg python3-netifaces \
        mpv netcat-openbsd fonts-dejavu-core \
        pulseaudio gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
        gstreamer1.0-pulseaudio python3-gst-1.0 \
        libasound2 libdbus-1-3 libegl1 libfontconfig1 libfreetype6 libgl1 \
        libglib2.0-0 libnss3 libxcb-cursor0 libxcb-icccm4 libxcb-image0 \
        libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 \
        libxcb-xinerama0 libxcb-xkb1 libxcomposite1 libxcursor1 libxdamage1 \
        libxi6 libxkbcommon0 libxkbcommon-x11-0 libxkbfile1 libxrandr2 \
        libxrender1 libxtst6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=fetch /anki /usr/local/share/anki
RUN ln -s /usr/local/share/anki/anki /usr/local/bin/anki

RUN useradd -m -u 1000 anki \
    && mkdir /volume /data \
    && chown anki:anki /data

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod 755 /entrypoint.sh

USER anki
WORKDIR /home/anki
ENTRYPOINT ["/entrypoint.sh"]
