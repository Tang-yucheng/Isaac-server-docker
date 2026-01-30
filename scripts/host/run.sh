#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Inputs
# ----------------------------
CUDA="${CUDA_VISIBLE_DEVICES:-0}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
COMPOSE_FILE="$REPO_ROOT/docker/docker-compose.yaml"

HOST_WS="${WORKSPACE:?Set WORKSPACE to host project path (e.g. WORKSPACE=~/IsaacLab)}"
CONTAINER_WS="/workspace/Project"

# ----------------------------
# Sanity checks
# ----------------------------
command -v docker >/dev/null 2>&1 || { echo "ERROR: docker not found"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "ERROR: docker compose not available"; exit 1; }

if command -v realpath >/dev/null 2>&1; then
  HOST_WS="$(realpath "$HOST_WS")"
fi
[[ -d "$HOST_WS" ]] || { echo "ERROR: WORKSPACE not a directory: $HOST_WS"; exit 1; }
[[ -f "$COMPOSE_FILE" ]] || { echo "ERROR: compose file not found: $COMPOSE_FILE"; exit 1; }

USER_NAME="${USER:-$(id -un 2>/dev/null || echo user)}"

# -----------------------------------------------------------------------------
# Ports strategy (one-shot containers):
#   - Default: do NOT publish any ports (safer).
#   - ENABLE_NOVNC=1  -> publish 8311(noVNC) and 5901(VNC, optional but handy for debug)
#   - ENABLE_FOXGLOVE=1 -> publish 8765 (foxglove websocket/bridge)
# -----------------------------------------------------------------------------
PORT_ARGS=()

if [[ "${ENABLE_NOVNC:-0}" == "1" ]]; then
  PORT_ARGS+=(-p 8311:8311 -p 5901:5901)
fi

if [[ "${ENABLE_FOXGLOVE:-0}" == "1" ]]; then
  PORT_ARGS+=(-p 8765:8765)
fi

# ----------------------------
# Python path priority
#   - If you want repo to override image: put $CONTAINER_WS first
#   - If you want image to override repo: swap the order
# ----------------------------
PYTHONPATH_VALUE="${CONTAINER_WS}:/workspace/isaaclab"

echo "[INFO] COMPOSE_FILE         = $COMPOSE_FILE"
echo "[INFO] HOST_WS              = $HOST_WS"
echo "[INFO] CONTAINER_WS         = $CONTAINER_WS"
echo "[INFO] CUDA_VISIBLE_DEVICES = $CUDA"
echo "[INFO] ENABLE_NOVNC         = ${ENABLE_NOVNC:-0}"
echo "[INFO] ENABLE_FOXGLOVE      = ${ENABLE_FOXGLOVE:-0}"
echo "[INFO] PYTHONPATH           = $PYTHONPATH_VALUE"
echo "[INFO] PORT_ARGS            = ${PORT_ARGS[*]:-(none)}"

docker compose -f "$COMPOSE_FILE" run --rm "${PORT_ARGS[@]}" \
  --name "${USER_NAME}-isaac-lab-gpu${CUDA}" \
  -e CUDA_VISIBLE_DEVICES="$CUDA" \
  -e ENABLE_NOVNC="${ENABLE_NOVNC:-0}" \
  -e ENABLE_FOXGLOVE="${ENABLE_FOXGLOVE:-0}" \
  -e WORKSPACE="$CONTAINER_WS" \
  -e PYTHONPATH="$PYTHONPATH_VALUE" \
  -v "$HOST_WS:$CONTAINER_WS" \
  --entrypoint /workspace/scripts/entrypoint.sh \
  isaac-lab \
  "$@"
