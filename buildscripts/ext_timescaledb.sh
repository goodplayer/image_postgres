#!/bin/bash

EXT_SRC=timescaledb-2.21.0.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf $EXT_SRC
cd timescaledb-2.21.0
PATH=$1:$PATH ./bootstrap
cd ./build && make && make install
