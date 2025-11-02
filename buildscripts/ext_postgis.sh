#!/bin/bash

EXT_SRC=postgis-3.5.3.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd postgis-3.5.3
./configure --with-pgconfig=$PG_CONFIG
make
make install
