#!/bin/bash

EXT_SRC=citus-13.1.0.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf $EXT_SRC
cd citus-13.1.0
./configure
make
make install
