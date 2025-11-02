#!/bin/bash

EXT_SRC=pg_readonly-master.zip
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
unzip ../buildpkg/$EXT_SRC
cd pg_readonly-master
PATH=$1:$PATH make
PATH=$1:$PATH make install
