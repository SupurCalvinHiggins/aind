# aind

## Overview

Qualitative researchers must maintain familiarity with **lots** of data over extended time periods. Anki, a spaced repetition system, may allow researchers to maintain familiarity with minimal review. Anki schedules review optimally: facts are reviewed right before they are forgotten. Retaining a single fact for 5 years costs only ~5 minutes. I estimate that retaining an hour-long interview for 5 years costs ~10 hours: 2 hours for encoding and 8 hours for review.

Despite these benefits, data security and privacy concerns prevent researchers from using Anki. Anki in Docker (`aind`) addresses these common concerns:
1. `aind` prevents accidental sharing of data over the Internet. 
2. `aind` stores data in encrypted, password-protected folders.
3. `aind` prevents accidentally saving unencrypted data.

`aind` provides a stronger security and privacy posture than storing and accessing data through Google Drive. 

## Installation

### Linux

1. Install [Docker Engine](https://docs.docker.com/engine/install/ubuntu/).
2. Download or clone this repository.

### Mac

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Download or clone this repository.

### Windows

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Download or clone this repository.

## Usage

The first time you run `aind`, you'll be asked to choose a password. **Remember your password**. Accessing your data is **impossible** without the password. 

### Linux

To start `aind`, run:
```bash
./start.sh
```
and enter your password. If you have a desktop open, an Anki window will appear. Otherwise, `aind` will print a URL: open it. 

To stop `aind`, quit Anki.

### Mac
To start `aind`, run:
```bash
./start.sh
```
enter your password, and open the printed URL.

To stop `aind`, quit Anki.

### Windows
To start `aind`, run:
```bash
./start.ps1
```
enter your password, and open the printed URL.

To stop `aind`, quit Anki.

### Advanced

## Backups

To backup your data, quit `aind` and copy the `encrypted-volume` folder to another drive. **Never share `encrypted-volume` publicly.** 

## Troubleshooting

Set `DEBUG=1` environment variable to display suppressed logs.

## Security

`aind` is secure against accidental data leakage and unsophisticated attackers. However, several attack vectors exist, including:
1. Supply chain attacks with container escape
2. Malicious cards with container escape
3. Local machine access (hot)

Although these attack vectors require significant expertise, frontier AI systems may allow unsophisticated actors to conduct such attacks. Personally, I wouldn't worry about it: at this threat level, ~all of your sofware is vulnerable.

## TODO: README updates needed for the Xpra remote-display swap

The remote-display stack changed from `Xvfb + fluxbox + x11vnc + websockify + noVNC` to a single `xpra` server, and `compose.web.yaml`/`compose.x11.yaml` were merged into one `compose.yaml` used on every OS. The following needs updating above (left as-is for you to edit):

- Remove any instructions/wording describing the noVNC/browser-only flow or the separate Linux-native X11-socket-passthrough path — there's now one unified flow on every OS.
- Document installing the native **Xpra client** (available for Linux/Mac/Windows) as the recommended way to connect — `start.sh`/`start.ps1` auto-detect it on the host and attach automatically if present.
- Document the printed HTML5 link (`http://127.0.0.1:10000/`) as the fallback when the native client isn't installed; `start.sh`/`start.ps1` print an explicit "install the native client for best performance" message in that case.
- Note the security-model detail: window *content* is always pixel data only, but two non-pixel convenience channels are enabled — clipboard sync and window-title forwarding (both deliberately left on, not disabled).
- Note the readiness mechanism: `start.sh`/`start.ps1` watch the container's own log output for its "ready" line (`docker compose logs -f anki`) rather than probing the network from the host, since the relay container's listening socket comes up before Anki/xpra inside it actually does.
- Update any port numbers in the instructions from the old noVNC port (`6080`) to the new xpra port (`10000`).
- Note that when the native client isn't found, `start.sh`/`start.ps1` now auto-open the link in the default browser (not just print it) — "fallback" no longer means "fully manual," just "no client installed."
- Note the audio channel: card audio is forwarded container → host speakers only; the reverse direction (host microphone → container) is explicitly disabled and was never enabled.
- Note that every other non-pixel xpra channel is now explicitly disabled rather than left at whatever the default is: file transfer, open-url, printing, pulseaudio, webcam, notifications, system tray, bell, and mdns are all off.
- Note the native-attach performance flags (`--speed=100 --min-speed=100`) used when auto-attaching, prioritizing responsiveness over image fidelity.
- Note the logging behavior: only the `anki` service's container log is persisted (`json-file`), and only because `start.sh`/`start.ps1` need to watch it for the ready line — it holds only banner/ready text, never the passphrase or (unless `DEBUG=1`) anki/xpra's own output. The `relay` service and the build step default to no persisted logs (`LOG_DRIVER=none`), settable to `json-file` via `DEBUG=1` for troubleshooting.
