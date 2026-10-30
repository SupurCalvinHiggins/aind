#!/bin/sh
set -eu

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
