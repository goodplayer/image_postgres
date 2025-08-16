#!/bin/bash

export HTTP_PROXY=10.11.0.3:1080
export HTTPS_PROXY=10.11.0.3:1080
export NO_PROXY=mirrors.ustc.edu.cn

podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step1_Core.dockerfile -t goodplayer/image_postgres_builder_core:v17.6 .
podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step2_Ext.dockerfile -t goodplayer/image_postgres_builder_ext:v17.6 .
podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step3_Release.dockerfile -t goodplayer/image_postgres:v17.6 .
