#!/bin/sh
set -eu

BAR='\033[1;36m'
TITLE='\033[1;97m'
LINK='\033[4;38;5;30m'
RESET='\033[0m'
LINK_URL='http://127.0.0.1:10000/'

quiet() {
    if [ "${DEBUG:-0}" = "1" ]; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

printf "\n${BAR}┃${RESET}  ${TITLE}Anki in Docker${RESET}\n"
printf "${BAR}┃${RESET}\n"

STEP=1

if [ ! -f /volume/gocryptfs.conf ]; then
    printf "${BAR}┃${RESET}  ${STEP}. Create your password below. Write it down: it cannot be recovered.\n"
    STEP=$((STEP + 1))
fi

printf "${BAR}┃${RESET}  ${STEP}. Enter your password below to unlock your data.\n"
STEP=$((STEP + 1))

printf "${BAR}┃${RESET}  ${STEP}. Once ready, Anki will open automatically.\n"
STEP=$((STEP + 1))

printf "${BAR}┃${RESET}  ${STEP}. To stop, quit Anki.\n"
printf "${BAR}┃${RESET}\n\n"

[ -f /volume/gocryptfs.conf ] || gocryptfs -init -q -scryptn 18 /volume
gocryptfs -nosyslog /volume /data
mkdir -p /data/anki

export XDG_RUNTIME_DIR=/tmp/xdg
mkdir -m 700 -p "$XDG_RUNTIME_DIR"

(
    i=0
    while [ $i -lt 30 ]; do
        if nc -z 127.0.0.1 10000 2>/dev/null; then
            printf "\n${BAR}┃${RESET}  ${TITLE}Anki in Docker is ready${RESET}\n"
            if [ "${XPRA_CLIENT:-0}" != "1" ]; then
                printf "${BAR}┃${RESET}\n"
                printf "${BAR}┃${RESET}  Native xpra client not found - recommended for best performance.\n"
                printf "${BAR}┃${RESET}  ${LINK}${LINK_URL}${RESET}\n"
            fi
            printf "\n"
            break
        fi
        sleep 1
        i=$((i + 1))
    done
) &

quiet xpra start :100 \
    --start-child="anki -b /data/anki" \
    --bind-tcp=0.0.0.0:10000 \
    --html=on \
    --daemon=no \
    --exit-with-children=yes \
    --clipboard=yes \
    --dpi=96 \
    --speaker=on \
    --microphone=no \
    --file-transfer=no \
    --open-url=no \
    --printing=no \
    --pulseaudio=no \
    --webcam=no \
    --notifications=no \
    --system-tray=no \
    --bell=no \
    --mdns=no \
    || true

fusermount3 -u /data
