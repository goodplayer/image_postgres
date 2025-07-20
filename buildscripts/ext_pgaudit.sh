#!/bin/bash

EXT_SRC=pgaudit-17.1.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf $EXT_SRC
cd pgaudit-17.1
make install USE_PGXS=1 PG_CONFIG=$PG_CONFIG
