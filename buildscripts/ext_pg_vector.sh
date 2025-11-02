#!/bin/bash

EXT_SRC=pgvector-0.8.0.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd pgvector-0.8.0
make
make install
