#!/bin/bash

EXT_SRC=pg_stat_kcache-REL2_3_0.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd pg_stat_kcache-REL2_3_0
PATH=$1:$PATH make
PATH=$1:$PATH make install
