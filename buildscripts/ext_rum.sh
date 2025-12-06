#!/bin/bash

EXT_SRC=rum-1.3.15.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config
export PATH=$PATH:$PG_CONFIG

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd rum-1.3.15
make USE_PGXS=1 PG_CONFIG=$PG_CONFIG
make USE_PGXS=1 PG_CONFIG=$PG_CONFIG install
