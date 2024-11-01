#!/bin/bash -xv

set -e

init_database() {
    if [ ! -n "$1" ]; then
        echo "no postgresql version specified"
        exit 1
    fi

    sudo mkdir -p /pgdata
    sudo mkdir -p /pgdata_wal
    sudo chown admin: /pgdata
    sudo chown admin: /pgdata_wal
    sudo -u admin echo "admin" > /tmp/default_passwd
    sudo -u admin /pg/bin/initdb -D /pgdata --waldir=/pgdata_wal \
        --auth=scram-sha-256 \
        --auth-host=scram-sha-256 \
        --auth-local=scram-sha-256 \
        --encoding=UTF8 \
        --data-checksums \
        --icu-locale=en_US \
        --locale=C.UTF-8 \
        --locale-provider=icu \
        --username=admin \
        --pwfile=/tmp/default_passwd \
        --wal-segsize=256
    sudo ln -s /pgdata /pgdata_v$1
    sudo chown admin: /pgdata_v$1
}

basic_configure() {
    cat /pgconf/hba_append >> /pgdata/pg_hba.conf
    echo "include_dir '/pgconf'" >> /pgdata/postgresql.conf
}

start_database() {
    # using exec to support passing signal(when docker stop) to postgres
    exec sudo -u admin /pg/bin/postgres -D /pgdata_v17
}

# main flow
# supporting entrypoint and cmd instructions in dockerfile
if [ $1 == "postgres" ]; then
    if [ ! -f "/pgdata/postgresql.conf" ]; then
        init_database $2
        basic_configure
    else
        #TODO check upgrade needed
        echo "already initialized!"
    fi
    start_database $2
else
    $@
fi

