#!/bin/bash

EXT_SRC=pgmq-1.6.1.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
tar xf $EXT_SRC
cd pgmq-1.6.1/pgmq-extension/
PATH=$1:$PATH make
PATH=$1:$PATH make install
