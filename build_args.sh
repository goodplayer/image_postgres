
# Setup http proxy
export HTTP_PROXY=http://10.11.0.31:1080
export HTTPS_PROXY=http://10.11.0.31:1080
export NO_PROXY=mirrors.ustc.edu.cn

# Output version
export BUILD_IMAGE_VERSION=v17.7
export ARG_CORE_IMAGE_VERSION=$BUILD_IMAGE_VERSION
export ARG_EXT_IMAGE_VERSION=$ARG_CORE_IMAGE_VERSION

# Base OS version
export ARG_OS_VERSION=13.1
# PG version
export ARG_PG_SOURCE_FILE=postgresql-17.7.tar.bz2
export ARG_PG_SOURCE_EXTRACT_FOLDER=postgresql-17.7
