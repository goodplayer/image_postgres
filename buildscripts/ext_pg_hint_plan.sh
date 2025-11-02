#!/bin/bash

EXT_SRC=pg_hint_plan-PG17.zip
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# compile sourcecode
unzip ../buildpkg/$EXT_SRC
cd pg_hint_plan-PG17
PATH=$1:$PATH make
PATH=$1:$PATH make install
