#!/bin/bash

##to support bash script debug, add -xv parameter above

set -e

force_link_current_database() {
    rm -f /pgdata/current
    ln -f -s /pgdata/$1 /pgdata/current
}

init_database() {
    if [ ! -n "$1" ]; then
        echo "no postgresql version specified"
        exit 1
    fi

    sudo mkdir -p /pgdata/$1
    sudo mkdir -p /pgdata_wal/$1
    sudo chown admin: /pgdata
    sudo chown admin: /pgdata/$1
    sudo chown admin: /pgdata_wal
    sudo chown admin: /pgdata_wal/$1
    sudo -u admin echo "admin" > /tmp/default_passwd
    sudo -u admin /pg/bin/initdb -D /pgdata/$1 --waldir=/pgdata_wal/$1 \
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
}

basic_configure() {
    # replace pg_hba.conf content
    cat /pgconf/hba_append > /pgdata/$1/pg_hba.conf
    # add include dir for cutomization configuration
    echo "include_dir '/pgconf'" >> /pgdata/$1/postgresql.conf
}

start_database() {
    # using exec to support passing signal(when docker stop) to postgres
    exec sudo -u admin /pg/bin/postgres -D /pgdata/$1
}

check_and_do_upgrade() {
    #Since upgrade script is not supported any more, here both max and min version are set to default version
    MIN=$1
    MAX=$1

    if [[ $MAX < `cat /pgdata/current/PG_VERSION` ]]; then
        echo "Newer version data found. Cannot upgrade and startup the instance. Found version:" `cat /pgdata/current/PG_VERSION`
        exit 1
    elif [[ `cat /pgdata/current/PG_VERSION` < $MIN ]]; then
        echo "Older version data found. Cannot upgrade and startup the instance. Found version:" `cat /pgdata/current/PG_VERSION`
        exit 1
    elif [[ $MAX = `cat /pgdata/current/PG_VERSION` ]]; then
        echo "Expected postgres data version. Continue startup."
    else
        # between two versions, need upgrade
        echo "As mentioned in the README.md, the upgrade between two supported versions are not supported any more."
        echo "Please use upgrade tools or follow the upgrade methods"
        exit 1
    fi
}

init_standby() {
    if [ ! -n "$1" ]; then
        echo "no postgresql version specified"
        exit 1
    fi

    sudo mkdir -p /pgdata/$1
    sudo mkdir -p /pgdata_wal/$1
    sudo chown admin: /pgdata
    sudo chown admin: /pgdata/$1
    sudo chown admin: /pgdata_wal
    sudo chown admin: /pgdata_wal/$1

    sudo -u admin PGPASSWORD=$5 /pg/bin/pg_basebackup -h $2 -p $3 -U $4 -F p -R -P -D /pgdata/$1 --waldir=/pgdata_wal/$1 -C -S $6
    sudo -u admin chmod 0700 /pgdata/$1
    sudo -u admin chmod 0700 /pgdata_wal/$1

    force_link_current_database $1
}

# main flow
# supporting entrypoint and cmd instructions in dockerfile
# $2 is version number
if [ $1 == "postgres" ]; then
    if [ ! -f "/pgdata/current/PG_VERSION" ]; then
        init_database $2
        basic_configure $2
        force_link_current_database $2
    else
        check_and_do_upgrade $2
    fi
    start_database $2
elif [ $1 == "new_standby" ]; then
    init_standby $2 $3 $4 $5 $6 $7
elif [ $1 == "showlibrary" ]; then
    cd /extensions && pgimagetool gen_shared_preload
elif [ $1 == "showcreateextension" ]; then
    cd /extensions && pgimagetool gen_create_extension
else
    $@
fi
