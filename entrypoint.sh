#!/bin/sh
set -eu

BAR='\033[1;36m'
TITLE='\033[1;97m'
LINK='\033[4;38;5;30m'
RESET='\033[0m'

printf "\n${BAR}┃${RESET}  ${TITLE}Anki in Docker${RESET}\n"
printf "${BAR}┃${RESET}\n"

STEP=1

if [ ! -f /volume/gocryptfs.conf ]; then
    printf "${BAR}┃${RESET}  ${STEP}. Create your password below. Write it down: it cannot be recovered.\n"
    STEP=$((STEP + 1))
fi

printf "${BAR}┃${RESET}  ${STEP}. Enter your password below to unlock your data.\n"
STEP=$((STEP + 1))

if [ "${WEB_UI:-0}" = "1" ]; then
    printf "${BAR}┃${RESET}  ${STEP}. Open this link in your browser:\n"
    printf "${BAR}┃${RESET}     ${LINK}http://127.0.0.1:6080/vnc.html?autoconnect=true&resize=scale${RESET}\n"
else
    printf "${BAR}┃${RESET}  ${STEP}. Your Anki window will open automatically.\n"
fi
STEP=$((STEP + 1))

printf "${BAR}┃${RESET}  ${STEP}. To stop, quit Anki.\n"
printf "${BAR}┃${RESET}\n\n"

[ -f /volume/gocryptfs.conf ] || gocryptfs -init -q -scryptn 18 /volume
gocryptfs -nosyslog /volume /data
mkdir -p /data/anki

export XDG_RUNTIME_DIR=/tmp/xdg
mkdir -m 700 -p "$XDG_RUNTIME_DIR"

if [ "${WEB_UI:-0}" = "1" ]; then
    export DISPLAY=:99
    mkdir -p -m 1777 /tmp/.X11-unix
    Xvfb :99 -screen 0 1280x800x24 -nolisten tcp &
    sleep 2
    x11vnc -display :99 -forever -shared -nopw -localhost -quiet &
    websockify --web /usr/share/novnc 6080 localhost:5900 &
fi

anki -b /data/anki || true
fusermount3 -u /data
