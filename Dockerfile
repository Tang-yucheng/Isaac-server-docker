FROM nvcr.io/nvidia/isaac-lab:2.1.0

SHELL ["/bin/bash", "-cx"]

# change apt source
RUN sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# install
RUN rm -rf /var/lib/apt/lists/* && \
    apt update && \
    apt install -y xvfb x11vnc novnc xterm fluxbox

# change pypi source
RUN mkdir -p /root/.pip && \
    echo '[global]' > /root/.pip/pip.conf && \
    echo 'index-url = https://pypi.tuna.tsinghua.edu.cn/simple' >> /root/.pip/pip.conf && \
    echo 'trusted-host = pypi.tuna.tsinghua.edu.cn' >> /root/.pip/pip.conf

RUN /workspace/isaaclab/_isaac_sim/kit/python/bin/python3 -m pip install toml
RUN /workspace/isaaclab/_isaac_sim/kit/python/bin/python3 -m pip install protobuf==3.19.0
RUN /workspace/isaaclab/_isaac_sim/kit/python/bin/python3 -m pip install mlflow
RUN /workspace/isaaclab/_isaac_sim/kit/python/bin/python3 -m pip install foxglove-sdk

COPY IsaacLab/ /workspace/isaaclab_211/
RUN ln -s /isaac-sim /workspace/isaaclab_211/_isaac_sim
RUN /workspace/isaaclab_211/_isaac_sim/kit/python/bin/python3 -m pip install -e /workspace/isaaclab_211/source/isaaclab
RUN /workspace/isaaclab_211/_isaac_sim/kit/python/bin/python3 -m pip install -e /workspace/isaaclab_211/source/isaaclab_assets
RUN /workspace/isaaclab_211/_isaac_sim/kit/python/bin/python3 -m pip install -e /workspace/isaaclab_211/source/isaaclab_mimic
RUN /workspace/isaaclab_211/_isaac_sim/kit/python/bin/python3 -m pip install -e /workspace/isaaclab_211/source/isaaclab_rl
RUN /workspace/isaaclab_211/_isaac_sim/kit/python/bin/python3 -m pip install -e /workspace/isaaclab_211/source/isaaclab_tasks

ENTRYPOINT ["/workspace/scripts/entrypoint.sh"]
