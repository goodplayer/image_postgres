#======================================
ARG OS_VERSION=13.1
# Step1: build
FROM debian:${OS_VERSION} AS build

# Custom parameters
ARG PG_SOURCE_FILE=postgresql-17.6.tar.bz2
ARG PG_SOURCE_EXTRACT_FOLDER=postgresql-17.6

# setup debian apt repository
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# update apt packages
RUN apt update && apt upgrade -y

#-------------------------------------

# install build dependencies
RUN apt install -y build-essential \
                llvm clang pkgconf bison flex \
                libicu-dev liblz4-dev \
                libzstd-dev libreadline-dev \
                libxslt1-dev libossp-uuid-dev zlib1g-dev \
                libssl-dev \
                unzip wget curl

# copy postgresql sourcecode
COPY buildpkgcore/${PG_SOURCE_FILE} /
# decompress sourcecode package
RUN tar xf ${PG_SOURCE_FILE} -C /
# compile postgresql
WORKDIR /${PG_SOURCE_EXTRACT_FOLDER}
RUN ./configure --prefix=/pg \
    --with-blocksize=16 \
    --with-segsize=4 \
    --with-wal-blocksize=16 \
    --with-llvm \
    --with-uuid=ossp \
    --with-libxml \
    --with-libxslt \
    --with-lz4 \
    --with-zstd \
    --with-ssl=openssl
RUN make -j
RUN make install
WORKDIR /${PG_SOURCE_EXTRACT_FOLDER}/contrib
RUN make -j
RUN make install

WORKDIR /
