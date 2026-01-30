#!/bin/bash

#docker-compose run --rm --service-ports \
#  --entrypoint /workspace/scripts/run.sh \
#  isaac-lab \
#  "$@"

CUDA=${CUDA_VISIBLE_DEVICES:-0}
CONTAINER_WS=/workspace/Project
# Default to loading ports from docker-compose.yml
PORT_ARGS="--service-ports"

if [ "$FOXGLOVE" = "1" ]; then
    # -p cannot be used with --service-ports
    # Note: If your yaml defines other necessary ports, append them here (e.g., -p 8384:8384 -p 8888:8888)
    PORT_ARGS="-p 8765:8765"
fi

sudo docker-compose run --rm $PORT_ARGS \
  --name ${USER}-isaac-lab-gpu${CUDA} \
  -e CUDA_VISIBLE_DEVICES=$CUDA \
  -e WORKSPACE=$CONTAINER_WS \
  -e PYTHONPATH="/workspace/isaaclab:$CONTAINER_WS" \
  -v ${WORKSPACE}:$CONTAINER_WS \
  --entrypoint /workspace/scripts/run.sh \
  isaac-lab \
  "$@"

