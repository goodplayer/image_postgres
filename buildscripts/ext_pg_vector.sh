#!/bin/bash

PGVECTOR_SRC=pgvector-0.8.0.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1

# compile sourcecode
tar xf $PGVECTOR_SRC
cd pgvector-0.8.0
make
make install
