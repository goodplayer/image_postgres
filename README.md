# Postgres Container

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
* [x] Supporting customize extension
    * Customize extensions by modifying .desc.json and .sh
* [ ] Supporting customize initdb parameters
* [ ] Supporting ssl configuration & custom CA
* [ ] Support postgresql archive mode
* [x] Support init standby database from primary database
    * run container with parameters: `new_standby 17 127.0.0.1 5432 repusr repusr replicaton_slot_name`
    * Note: must keep configurations same between primary instance and standby instances, otherwise postgres may reject
      to start
* [x] Postgres image tool - support building images
    * Support build script
    * Support dependency installation in build and runtime stages
* [x] Postgres Extensions
    * [x] distributed: citus
    * [x] gis: postgis
    * [x] util: pg_cron
    * [x] util: pg_readonly
    * [x] vector: pgvector

##### Pending list

* Decouple new instance & new standby with upgrade
    * upgrade requires manual work, so will be moved separately
    * upgrade solutions will be provided separately
    * some extensions may not be supported any more, so leading to incompatible
    * document best practise of major version upgrade
* Shared build scripts
    * E.g. pg_duckdb and pg_mooncake both depend on duckdb
* Library load configurator
* Build script stages
    * User enablement, including shared libraries and create extension

## 2. Getting started

Start new instance

```shell
# create container
podman create --name sample_pg \
    -p 5432:5432 \
    -v /home/server/pgdata:/pgdata \
    -v /home/server/pgdata_wal:/pgdata_wal \
    goodplayer/image_postgres:v17.5

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
podman run --name pg_standby_init \
    -v /home/server/demo1/pgdata:/pgdata \
    -v /home/server/demo1/pgdata_wal:/pgdata_wal \
    goodplayer/image_postgres:v17.5 new_standby 17 10.11.0.5 5432 repusr repusr rep_slot_1

podman rm pg_standby_init

podman create --name sample_pg \
    -p 5432:5432 \
    -v /home/server/demo1/pgdata:/pgdata \
    -v /home/server/demo1/pgdata_wal:/pgdata_wal \
    -v /home/server/01-pgcustom.conf:/pgconf/01-pgcustom.conf \
    goodplayer/image_postgres:v17.5

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

Note 1: Configure `shared_preload_libraries` parameter to enable specific extensions. Use comma if multiple libraries
required.

* TODO specify parameters, mount required files

## 3. Build image(postgresql 17.5)

1. Download `postgresql-17.5.tar.bz2` file from postgresql website
    * Please refer to the Dockerfile for the actual files to download
2. Run builder
    * `podman build --no-cache --force-rm --squash-all -t goodplayer/image_postgres:v17.5 .`
3. Push to registry
    * `podman login -u docker -p docker docker-push.registry.internal:5001`
    * `podman push goodplayer/image_postgres:v17.5 docker-push.registry.internal:5001/goodplayer/image_postgres:v17.5`

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

## A. References

* Offical postgres image: [https://github.com/docker-library/postgres](https://github.com/docker-library/postgres)
* PGDG: [https://wiki.postgresql.org/wiki/Apt](https://wiki.postgresql.org/wiki/Apt)
* PGNX: [https://pgxn.org/](https://pgxn.org/)
* Pisty: [https://pigsty.cc/](https://pigsty.cc/)
* pgxman: [https://pgxman.com/](https://pgxman.com/)
