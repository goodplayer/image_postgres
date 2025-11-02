#!/bin/bash

EXT_SRC=postgresql-hll-2.18.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd postgresql-hll-2.18
PATH=$1:$PATH make
PATH=$1:$PATH make install
