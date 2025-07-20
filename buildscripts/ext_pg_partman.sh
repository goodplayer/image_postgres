#!/bin/bash

EXT_SRC=pg_partman-5.2.4.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf $EXT_SRC
cd pg_partman-5.2.4
PATH=$1:$PATH make install
