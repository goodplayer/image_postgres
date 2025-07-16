#!/bin/bash

PGCRON_SRC=pg_cron-1.6.5.zip
PWD_DIR=`pwd`
export PG_CONFIG=$1

# compile sourcecode
unzip $PGCRON_SRC
cd pg_cron-1.6.5
make
make install
