#!/bin/bash


EXT_SRC=pg_bigm-1.2-20240606.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd pg_bigm-1.2-20240606
make USE_PGXS=1 PG_CONFIG=$PG_CONFIG
make USE_PGXS=1 PG_CONFIG=$PG_CONFIG install
