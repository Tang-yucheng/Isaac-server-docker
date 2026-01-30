#!/bin/bash

docker-compose run --rm --service-ports \
  --entrypoint bash \
  -e CUDA_VISIBLE_DEVICES=0 \
  isaac-lab
