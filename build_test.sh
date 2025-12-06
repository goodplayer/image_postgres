#!/bin/bash

set -e

export HTTP_PROXY=http://10.11.0.31:1080
export HTTPS_PROXY=http://10.11.0.31:1080
export NO_PROXY=mirrors.ustc.edu.cn

podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step1_Core.dockerfile -t goodplayer/image_postgres_builder_core:v17.6 .
podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step2.1_ExtTest.dockerfile -t goodplayer/image_postgres_builder_ext:v17.6 .
