#!/bin/bash

set -e

. ./build_args.sh

podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step1_Core.dockerfile -t goodplayer/image_postgres_builder_core:$BUILD_IMAGE_VERSION \
 --build-arg OS_VERSION=$ARG_OS_VERSION \
 --build-arg PG_SOURCE_FILE=$ARG_PG_SOURCE_FILE \
 --build-arg PG_SOURCE_EXTRACT_FOLDER=$ARG_PG_SOURCE_EXTRACT_FOLDER \
 .
podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step2_Ext.dockerfile -t goodplayer/image_postgres_builder_ext:$BUILD_IMAGE_VERSION \
 --build-arg CORE_IMAGE_VERSION=$ARG_CORE_IMAGE_VERSION \
 .
# podman run --rm -it goodplayer/image_postgres_builder_ext:v17.6 bash
podman build --http-proxy --no-cache --force-rm --squash-all -f Dockerfile.Step3_Release.dockerfile -t goodplayer/image_postgres:$BUILD_IMAGE_VERSION \
 --build-arg OS_VERSION=$ARG_OS_VERSION \
 --build-arg EXT_IMAGE_VERSION=$ARG_EXT_IMAGE_VERSION \
 .
