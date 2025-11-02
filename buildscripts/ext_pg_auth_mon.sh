#!/bin/bash


EXT_SRC=pg_auth_mon-3.0.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd pg_auth_mon-3.0
PATH=$1:$PATH make install
