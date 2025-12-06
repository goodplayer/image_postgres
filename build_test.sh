#!/bin/bash

set -e

. ./build_args.sh

podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step1_Core.dockerfile -t goodplayer/image_postgres_builder_core:$BUILD_IMAGE_VERSION \
 --build-arg OS_VERSION=$ARG_OS_VERSION \
 --build-arg PG_SOURCE_FILE=$ARG_PG_SOURCE_FILE \
 --build-arg PG_SOURCE_EXTRACT_FOLDER=$ARG_PG_SOURCE_EXTRACT_FOLDER \
 .
podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step2.1_ExtTest.dockerfile -t goodplayer/image_postgres_builder_ext:$BUILD_IMAGE_VERSION \
 --build-arg CORE_IMAGE_VERSION=$ARG_CORE_IMAGE_VERSION \
 .
