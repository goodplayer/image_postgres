#!/bin/bash


EXT_SRC=paradedb-0.17.0.tar.gz
PWD_DIR=`pwd`
export PG_CONFIG=$1/pg_config

# load rust dev env
. "$HOME/.cargo/env"

# compile sourcecode
tar xf ../buildpkg/$EXT_SRC
cd paradedb-0.17.0/pg_search/

# specify cargo-pgrx version according to the requirement in the sourcecode
cargo install cargo-pgrx --version 0.15.0 --locked

cargo pgrx init --pg17=$PG_CONFIG
PATH=$1:$PATH cargo pgrx install --profile release
