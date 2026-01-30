#!/usr/bin/env bash
set -euo pipefail

CUDA="${CUDA_VISIBLE_DEVICES:-0}"

# repo root
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

COMPOSE_FILE="$REPO_ROOT/docker/docker-compose.yaml"

HOST_WS="${WORKSPACE:?Set WORKSPACE to host project path (e.g. WORKSPACE=~/isaac_ws/IsaacLab)}"
CONTAINER_WS="/workspace/Project"

PORT_ARGS="--service-ports"
if [ "${FOXGLOVE:-0}" = "1" ]; then
  PORT_ARGS="-p 8765:8765"
fi

docker compose -f "$COMPOSE_FILE" run --rm $PORT_ARGS \
  --name "${USER}-isaac-lab-gpu${CUDA}" \
  -e CUDA_VISIBLE_DEVICES="$CUDA" \
  -e WORKSPACE="$CONTAINER_WS" \
  -e PYTHONPATH="/workspace/isaaclab:$CONTAINER_WS" \
  -v "$HOST_WS:$CONTAINER_WS" \
  --entrypoint /workspace/scripts/entrypoint.sh \
  isaac-lab \
  "$@"
