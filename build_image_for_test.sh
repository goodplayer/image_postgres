#!/bin/bash

export HTTP_PROXY=10.11.0.3:1080
export HTTPS_PROXY=10.11.0.3:1080
export NO_PROXY=mirrors.ustc.edu.cn

#podman build --env=HTTP_PROXY=10.11.0.3:1080 --env=HTTPS_PROXY=10.11.0.3:1080 --env=no_proxy=mirrors.ustc.edu.cn \
# --force-rm -t goodplayer/image_postgres:test_img .

podman build --http-proxy --force-rm -t goodplayer/image_postgres:test_img .
