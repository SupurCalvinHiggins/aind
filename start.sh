#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p encrypted-volume

if [ "$(uname -s)" = "Linux" ] && [ -n "${DISPLAY:-}" ] && [ -d /tmp/.X11-unix ]; then
    COMPOSE_FILE=compose.x11.yaml
    xhost +SI:localuser:"$(whoami)" >/dev/null 2>&1 || true
else
    COMPOSE_FILE=compose.web.yaml
fi

quiet() {
    if [ "${DEBUG:-0}" = "1" ]; then
        "$@"
    else
        "$@" >/dev/null 2>&1
    fi
}

trap 'quiet docker compose -f "$COMPOSE_FILE" down' EXIT INT TERM

quiet docker compose -f "$COMPOSE_FILE" create --build
quiet docker compose -f "$COMPOSE_FILE" start relay || true
docker start -ai "$(docker compose -f "$COMPOSE_FILE" ps -a -q anki)"
