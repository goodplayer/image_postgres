#!/bin/bash

EXT_SRC=apache-age-1.6.0-src.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd apache-age-1.6.0
make PG_CONFIG=$PG_CONFIG install
