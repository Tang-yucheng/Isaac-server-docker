#!/bin/bash
set -euo pipefail
set -x

# -----------------------------------------------------------------------------
# GPU/图形相关环境变量（某些环境下有助于选择 nvidia 实现）
# -----------------------------------------------------------------------------
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1
export __VK_LAYER_NV_optimus=NVIDIA_only

# -----------------------------------------------------------------------------
# 运行时参数（外部可通过 -e 覆盖）
# DISPLAY/RESOLUTION：用于 Xvfb 虚拟显示与 noVNC
# WORKSPACE：容器内挂载的项目根目录
# -----------------------------------------------------------------------------
export DISPLAY="${DISPLAY:-:1}"
export RESOLUTION="${RESOLUTION:-1920x1080x24}"
export WORKSPACE="${WORKSPACE:-/workspace}"

# IsaacLab 启动脚本：加 -p 表示使用 Isaac Sim/Kit 的 Python 环境执行 Python 命令
KITPY="/workspace/isaaclab/isaaclab.sh"

# -----------------------------------------------------------------------------
# 可选：启动 noVNC（外层脚本需同时做端口映射：8311(noVNC) / 5901(VNC)）
# 约定：ENABLE_NOVNC=1 才开启
# -----------------------------------------------------------------------------
if [[ "${ENABLE_NOVNC:-0}" == "1" ]]; then
  Xvfb "${DISPLAY}" -screen 0 "${RESOLUTION}" &
  sleep 2
  fluxbox &
  x11vnc -display "${DISPLAY}" -nopw -forever -shared -rfbport 5901 &
  /usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 8311 &
fi

# -----------------------------------------------------------------------------
# 进入工作区（必须存在）
# -----------------------------------------------------------------------------
[[ -d "${WORKSPACE}" ]] || { echo "ERROR: WORKSPACE not a directory: ${WORKSPACE}"; exit 1; }
cd "${WORKSPACE}"

# -----------------------------------------------------------------------------
# Git safe.directory：解决容器内以 root 使用挂载目录时的安全报错
# 采用“幂等”写法：已存在则不重复追加
# -----------------------------------------------------------------------------
git config --global --get-all safe.directory | grep -Fxq "${WORKSPACE}" \
  || git config --global --add safe.directory "${WORKSPACE}"

# -----------------------------------------------------------------------------
# Python 依赖安装（使用 Kit Python 环境）
# 说明：-e 安装 editable，便于你在挂载目录里修改代码立即生效
# -----------------------------------------------------------------------------
"$KITPY" -p -m pip install -U pip

# "$KITPY" -p -m pip install -e ./envs/lib/IsaacLab/source/isaaclab
# "$KITPY" -p -m pip install -e ./reinforcement_learning/lib/rsl_rl
# "$KITPY" -p -m pip install -e ./reinforcement_learning/lib/skrl
# "$KITPY" -p -m pip install -e ./reinforcement_learning/lib/stable-baselines3

# ./lib/IsaacLab/isaaclab.sh --install
"$KITPY" -p -m pip install -e lib/rsl_rl
"$KITPY" -p -m pip install -e lib/skrl
"$KITPY" -p -m pip install -e lib/stable-baselines3
"$KITPY" -p -m pip install -e .

"$KITPY" -p -m pip install rtree

# -----------------------------------------------------------------------------
# 最终执行：进入 IsaacLab（-p 表示用 Kit Python/IsaacSim 环境运行）
# "$@"：把外部传入参数原样转发
# -----------------------------------------------------------------------------
exec "$KITPY" -p "$@"
