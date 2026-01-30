FROM nvcr.io/nvidia/isaac-lab:2.1.0
# FROM nvcr.io/nvidia/isaac-lab:2.2.0

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# apt 镜像源（按需）
RUN sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g; s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends xvfb x11vnc novnc xterm fluxbox \
 && rm -rf /var/lib/apt/lists/*

# pip 镜像源（root）
RUN mkdir -p /root/.pip \
 && printf "[global]\nindex-url=https://pypi.tuna.tsinghua.edu.cn/simple\ntrusted-host=pypi.tuna.tsinghua.edu.cn\n" > /root/.pip/pip.conf

# 用 isaaclab.sh -p（避免写死 Kit Python 路径）
RUN cd /workspace/isaaclab \
 && ./isaaclab.sh -p -m pip install -U pip \
 && ./isaaclab.sh -p -m pip install foxglove-sdk loguru mlflow toml
