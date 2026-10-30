#!/bin/sh
set -eu
cd "$(dirname "$0")"
docker compose -f compose.web.yaml down
docker compose -f compose.x11.yaml down
