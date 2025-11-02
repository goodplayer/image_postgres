#!/bin/bash


EXT_SRC=VectorChord-0.4.3.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# load rust dev env
. "$HOME/.cargo/env"

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd VectorChord-0.4.3
PATH=$1:$PATH make build
PATH=$1:$PATH make install
