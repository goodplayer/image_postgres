#!/bin/bash

EXT_SRC=pg_cron-1.6.5.zip
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
unzip ../buildpkg/$EXT_SRC
cd pg_cron-1.6.5
make
make install
