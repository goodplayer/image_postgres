#!/bin/bash

export HTTP_PROXY=10.11.0.3:1080
export HTTPS_PROXY=10.11.0.3:1080
export NO_PROXY=mirrors.ustc.edu.cn

podman build --http-proxy --force-rm --no-cache --squash-all -t goodplayer/image_postgres:v17.6 .
