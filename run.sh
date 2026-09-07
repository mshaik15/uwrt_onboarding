#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

xhost +local:docker >/dev/null 2>&1 || true

if ! docker image inspect uwrt >/dev/null 2>&1; then
  docker build -t uwrt .
fi

if docker ps -a --format '{{.Names}}' | grep -qx uwrt_humble; then
  docker start uwrt_humble >/dev/null
  docker exec -it uwrt_humble bash
else
  docker run -it --name uwrt_humble \
    --network host --ipc host \
    --device /dev/dri \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$(pwd)":/root/ws \
    uwrt bash
fi