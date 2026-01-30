#!/bin/bash
set -x

export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1
export __VK_LAYER_NV_optimus=NVIDIA_only
export DISPLAY=${DISPLAY}

if [ "$ENABLE_NOVNC" = "true" ]; then
  Xvfb ${DISPLAY} -screen 0 ${RESOLUTION} &
  sleep 2
  fluxbox &
  x11vnc -display ${DISPLAY} -nopw -forever -shared -rfbport 5901 &
  /usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 8311 &
fi

cd ${WORKSPACE}
git config --global --add safe.directory ${WORKSPACE}
/workspace/isaaclab/_isaac_sim/python.sh -m pip install -e ./rsl_rl/
/workspace/isaaclab/_isaac_sim/python.sh -m pip install -e ./InstinctLab/source/instinctlab/
/workspace/isaaclab/_isaac_sim/python.sh -m pip install protobuf==3.20.1
exec /workspace/isaaclab/isaaclab.sh -p "$@"
#exec /workspace/isaaclab/_isaac_sim/kit/python/bin/python3 "$@"
