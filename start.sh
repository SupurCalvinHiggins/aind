#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p encrypted-volume

if [ "$(uname -s)" = "Linux" ] && [ -n "${DISPLAY:-}" ] && [ -d /tmp/.X11-unix ]; then
    xhost +SI:localuser:"$(whoami)" >/dev/null 2>&1 || true
    docker compose -f compose.x11.yaml run --rm anki
else
    echo "Open: http://127.0.0.1:6080/vnc.html?autoconnect=true&resize=scale"
    docker compose -f compose.web.yaml run --rm anki
fi
