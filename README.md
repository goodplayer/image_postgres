# Postgres Container

<!-- TOC -->
* [Postgres Container](#postgres-container)
  * [1. Features](#1-features)
        * [Pending list](#pending-list)
  * [2. Getting started](#2-getting-started)
  * [3. Build image(postgresql 17.6)](#3-build-imagepostgresql-176)
    * [Require modification when upgrade to a new version](#require-modification-when-upgrade-to-a-new-version)
    * [Customization](#customization)
      * [1. Customize debian repository](#1-customize-debian-repository)
      * [2. Customize postgresql configure files](#2-customize-postgresql-configure-files)
    * [Test scenarios](#test-scenarios)
  * [4. Upgrade Guide](#4-upgrade-guide)
    * [4.1. Postgres Upgrade Methods](#41-postgres-upgrade-methods)
      * [4.1.1. Backup - Restore](#411-backup---restore)
      * [4.1.2. In-place](#412-in-place)
      * [4.1.3. New Instance - Logical Replication (Suggested)](#413-new-instance---logical-replication-suggested)
  * [A. References](#a-references)
  * [B. Example of use](#b-example-of-use)
<!-- TOC -->

This is the containerized Postgres image source code.

The purpose of the repo is

1. Provide full-featured and out-of-box postgres container image
2. Make it easy to customize your container

## 1. Features

* [x] Postgres container with contrib extensions
* [x] Supporting version specific data folder for major version upgrading
* [x] Supporting auto-upgrade at container startup with the recent two postgres major versions(latest and one previous)
* [x] Supporting customizing postgres configuration
    * Mapping configure files: \*.conf => /pgconf/\*.conf
* [x] Supporting customizing data folder
    * Mapping data folder: <folder> => /pgdata
    * Mapping data wal folder: <folder> => /pgdata_wal
* [x] Supporting starting container from both fresh new and existing instance
* [x] Supporting safe container stop
* [x] Larger uid and gid of data files
    * `Note`: please ensure the uid and gid when mounting a volumn
    * Current `UID`: 30000
    * Current `GID`: 30000
* [x] Support install dependencies for extensions
* [x] Support customize extension
    * Customize extensions by modifying .desc.json and .sh
* [ ] Support customize initdb parameters
* [ ] Support ssl configuration & custom CA
* [ ] Support postgresql archive mode
* [x] Support initializing SQL file for setting up the primary database
* [ ] Support agent for postgresql
* [x] Support init standby database from primary database
    * run container with parameters: `new_standby 17 127.0.0.1 5432 repusr repusr replicaton_slot_name`
    * Note: must keep configurations same between primary instance and standby instances, otherwise postgres may reject
      to start
* [x] Postgres image tool - support building images
    * Support build script
    * Support dependency installation in build and runtime stages
    * Generate `create extension` clauses for plugins
    * Generate `shared_preload_libraries` clauses for plugins
* [x] Provide both release image and build image
    * Release image: used for production
    * Build image: for building extensions
* [x] Postgres Extensions
    * [x] datatype: hll
    * [x] distributed: citus
    * [x] fts: pg_bigm
    * [x] fts: pg_search
    * [x] gis: postgis
    * [x] graph: apache age
    * [x] timeseries: timescaledb
    * [x] util: pg_auth_mon
    * [x] util: pg_cron
    * [x] util: pg_hint_plan
    * [x] util: pg_partman
    * [x] util: pg_readonly
    * [x] util: pg_stat_kcache
    * [x] util: pgaudit
    * [x] util: pgmq
    * [x] vector: pgvector
    * [x] vector: VectorChord
* [x] Postgres removed extensions:
    * (None)

##### Pending list

* Decouple new instance & new standby with upgrade
    * upgrade requires manual work, so will be moved separately
    * upgrade solutions will be provided separately
    * some extensions may not be supported any more, so leading to incompatible
    * document best practise of major version upgrade
* Shared build scripts
    * E.g. pg_duckdb and pg_mooncake both depend on duckdb
* Library load configurator
* Evaluate performance impact of extensions on each stage of loading
* Extensions to add
    * https://github.com/omniti-labs/pg_jobmon
        * Optional required by pg_partman
    * https://github.com/duckdb/pg_duckdb - OLAP
    * https://git.postgresql.org/gitweb/?p=pgfincore.git;a=summary
    * https://github.com/EnterpriseDB/repmgr
    * https://github.com/HypoPG/hypopg
    * https://github.com/mhagander/bgw_replstatus
    * https://github.com/tvondra/count_distinct
    * https://github.com/sraoss/pg_ivm
    * https://github.com/2ndQuadrant/pglogical
    * https://github.com/pgbackrest/pgbackrest
    * https://github.com/HexaCluster/credcheck
    * https://github.com/lacanoid/pgddl
    * https://github.com/dalibo/emaj
    * https://github.com/df7cb/pg_filedump
    * https://github.com/xocolatl/extra_window_functions
    * https://github.com/tvondra/geoip
    * https://github.com/RhodiumToad/ip4r
    * https://github.com/orafce/orafce
    * https://github.com/MigOpsRepos/pg_dbms_job
    * https://github.com/hapostgres/pg_auto_failover
    * https://github.com/EnterpriseDB/pg_failover_slots
    * https://github.com/vibhorkum/pg_background
    * https://github.com/ossc-db/pg_bulkload
    * https://github.com/EnterpriseDB/pg_catcheck
    * https://github.com/lemoineat/pg_fkpart
    * https://github.com/postgrespro/rum
    * https://github.com/ChenHuajun/pg_roaringbitmap
    * https://github.com/amutu/zhparser
    * https://github.com/jaiminpan/pg_jieba
    * https://github.com/zachasme/h3-pg
    * https://github.com/reorg/pg_repack
    * https://github.com/eulerto/pg_similarity
    * https://github.com/pgRouting/pgrouting
    * https://github.com/timescale/pgvectorscale
    * https://github.com/df7cb/postgresql-unit
    * https://github.com/alitrack/duckdb_fdw
    * https://github.com/jirutka/smlar
    * https://www.pgpool.net/mediawiki/index.php/Main_Page

## 2. Getting started

Start new instance

```shell
# create container
podman create --name sample_pg \
    -p 5432:5432 \
    -v /home/server/pgdata:/pgdata \
    -v /home/server/pgdata_wal:/pgdata_wal \
    goodplayer/image_postgres:v17.6

# start container
podman start sample_pg

# view log
podman logs -f sample_pg

# stop container
podman stop -t 120 sample_pg

# remove container
podman rm sample_pg
```

New standby instance from primary

```shell
podman run --rm --name pg_standby_init \
    -v /home/server/demo1/pgdata:/pgdata \
    -v /home/server/demo1/pgdata_wal:/pgdata_wal \
    goodplayer/image_postgres:v17.6 new_standby 17 10.11.0.5 5432 repusr repusr rep_slot_1

podman create --name sample_pg \
    -p 5432:5432 \
    -v /home/server/demo1/pgdata:/pgdata \
    -v /home/server/demo1/pgdata_wal:/pgdata_wal \
    -v /home/server/01-pgcustom.conf:/pgconf/01-pgcustom.conf \
    goodplayer/image_postgres:v17.6

podman start sample_pg
```

Default settings for container mapping:

* Postgres port: `5432`
* Postgres data folder: `/pgdata`
* Postgres data wal folder: `/pgdata_wal`
* Custom postgres conf folder: `/pgconf`

Custom configure:

```shell
# create custom conf file
touch /home/server/01-pgcustom.conf

# add parameter as a mounted file:
# -v /home/server/01-pgcustom.conf:/pgconf/01-pgcustom.conf
```

**Important**

* Change the superuser password after initialized. The superuser is `admin`
* Change the replication user password after initialized. The replication user is `replica`

**Note 1**: Configure `shared_preload_libraries` parameter to enable specific extensions. Use comma if multiple
libraries
required. The following command can be used to generate related clauses:

* Generate preload library configure
    * `podman run --rm -it goodplayer/image_postgres:v17.6 showlibrary`

**Note 2**: Enable extensions by `CREATE EXTENSION` in opened databases:

* Generate `CREATE EXTENSION` clauses
    * `podman run --rm -it goodplayer/image_postgres:v17.6 showcreateextension`

## 3. Build image(postgresql 17.6)

1. Download `postgresql-17.6.tar.bz2` file from postgresql website
    * Please refer to the Dockerfile for the actual files to download
    * Additional files are required as well, refer to the below
2. Run builder
    * `podman build --no-cache --force-rm --squash-all -f Dockerfile.Step1_Core.dockerfile -t goodplayer/image_postgres_builder_core:v17.6 .`
    * `podman build --no-cache --force-rm --squash-all -f Dockerfile.Step2_Ext.dockerfile -t goodplayer/image_postgres_builder_ext:v17.6 .`
    * `podman build --no-cache --force-rm --squash-all -f Dockerfile.Step3_Release.dockerfile -t goodplayer/image_postgres:v17.6 .`
3. Push to registry
    * `podman login -u docker -p docker docker-push.registry.internal:5001`
    * `podman push goodplayer/image_postgres:v17.6 docker-push.registry.internal:5001/goodplayer/image_postgres:v17.6`

Additional files to downloads

* files described in .sh files in `buildscripts` folder
* files described in .sh files in `buildtool` folder

### Require modification when upgrade to a new version

1. ARGs at the beginning in Dockerfile: source files to build
2. CMD parameter in Dockerfile: data folder link name
3. MIN and MAX version in check version function in entrypoint.sh: version check for upgrade

### Customization

#### 1. Customize debian repository

Edit `debian.sources` file before building the image.

#### 2. Customize postgresql configure files

Edit files in `pgconf` folder before building the image.

The files will be the default configuration in the image.

### Test scenarios

* Startup on fresh new instance
* Restart from an existing instance
* Restart on an old instance of supported versions
* Restart on an old instance of unsupported versions(instance version < minimum supported versions)
* Restart on an new instance of unsupported versions(instance version > maximum supported versions)
* Stop the instance gracefully

## 4. Upgrade Guide

`Note: This image does not contain out-of-box upgrade scripts. For the details, please refer to the below.`

### 4.1. Postgres Upgrade Methods

#### 4.1.1. Backup - Restore

1. Stop the postgres instance of the old version
2. Backup the database
3. Create a new postgres instance of the new version
4. Restore the database
5. Start the new postgres instance

The drawback of this method:

1. Take long time to back up and restore. This may cause long downtime.

#### 4.1.2. In-place

1. Stop the postgres instance of the old version
2. Invoke pg_upgrade for in-place upgrade
3. Start the postgres instance with the new version

The drawback of this method:

1. Even though it takes less time than Backup-Restore method, it still needs long downtime.

#### 4.1.3. New Instance - Logical Replication (Suggested)

1. Start a new postgres instance of the new version and run as a logical standby server from the primary.
    * This may need a full backup from the primary ahead.
2. Wait for the new standby server catching up with the primary
3. Switch the primary to readonly mode and wait for the standby server has all the updates from the primary.
4. Stop the old primary and promote the standby to the new primary.
5. Switch clients to the new primary.

The drawback of this method:

1. No downtime but the switching plan is complex.
2. Drawbacks of logical replication
    * Primary key is required in order to precisely locate changes
    * TOAST table issue: old value may not be transferred by default
    * DDL synchronization is not supported

## A. References

* Offical postgres image: [https://github.com/docker-library/postgres](https://github.com/docker-library/postgres)
* PGDG: [https://wiki.postgresql.org/wiki/Apt](https://wiki.postgresql.org/wiki/Apt)
    * https://www.postgresql.org/download/products/6-postgresql-extensions/
* PGNX: [https://pgxn.org/](https://pgxn.org/)
* Pisty: [https://pigsty.cc/](https://pigsty.cc/)
* pgxman: [https://pgxman.com/](https://pgxman.com/)

## B. Example of use

//TODO

