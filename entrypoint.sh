#!/bin/sh
set -eu

BAR='\033[1;36m'
TITLE='\033[1;97m'
LINK='\033[4;38;5;30m'
RESET='\033[0m'
LINK_URL='http://127.0.0.1:6080/vnc.html?autoconnect=true&resize=remote'

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

if [ "${WEB_UI:-0}" = "1" ]; then
    printf "${BAR}┃${RESET}  ${STEP}. A link will appear below once Anki is ready. Open it in your browser.\n"
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
    quiet Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp &
    sleep 2
    mkdir -p "$HOME/.fluxbox"
    cat > "$HOME/.fluxbox/apps" <<'EOF'
[app] (title=Anki)
  [Maximized]	{yes}
[end]
EOF
    printf 'session.screen0.toolbar.visible: false\n' > "$HOME/.fluxbox/init"
    quiet fluxbox &
    sleep 1
    quiet x11vnc -display :99 -forever -shared -nopw -localhost -xrandr -threads -wait 5 -defer 5 -quiet &
    quiet websockify --web /usr/share/novnc 6080 localhost:5900 &
fi

if command -v xdotool >/dev/null 2>&1; then
    (
        i=0
        while [ $i -lt 30 ]; do
            if xdotool search --name '^Anki$' >/dev/null 2>&1; then
                if [ "${WEB_UI:-0}" = "1" ]; then
                    printf "\n${BAR}┃${RESET}  ${TITLE}Anki in Docker is ready${RESET}\n"
                    printf "${BAR}┃${RESET}\n"
                    printf "${BAR}┃${RESET}  Open this link:\n"
                    printf "${BAR}┃${RESET}     ${LINK}${LINK_URL}${RESET}\n\n"
                else
                    printf "\n${BAR}┃${RESET}  ${TITLE}Anki in Docker is ready${RESET}\n\n"
                fi
                break
            fi
            sleep 1
            i=$((i + 1))
        done
    ) &
elif [ "${WEB_UI:-0}" = "1" ]; then
    printf "\n${BAR}┃${RESET}  Open this link:\n"
    printf "${BAR}┃${RESET}     ${LINK}${LINK_URL}${RESET}\n\n"
fi

quiet anki -b /data/anki || true
fusermount3 -u /data
