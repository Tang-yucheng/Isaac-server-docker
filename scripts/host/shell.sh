#!/usr/bin/env bash
set -euo pipefail

CUDA="${CUDA_VISIBLE_DEVICES:-0}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$REPO_ROOT/docker/docker-compose.yaml"

HOST_WS="${WORKSPACE:?Set WORKSPACE to host project path}"
CONTAINER_WS="/workspace/Project"

docker compose -f "$COMPOSE_FILE" run --rm -it \
  --name "${USER}-isaac-lab-gpu${CUDA}-shell" \
  -e CUDA_VISIBLE_DEVICES="$CUDA" \
  -e WORKSPACE="$CONTAINER_WS" \
  -e PYTHONPATH="/workspace/isaaclab:$CONTAINER_WS" \
  -v "$HOST_WS:$CONTAINER_WS" \
  --entrypoint bash \
  isaac-lab
