# Postgres Container

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
* [ ] Supporting customize extension
* [ ] Supporting customize initdb parameters
* [ ] Supporting both primary and standby instance image
* [ ] Supporting ssl configuration & custom CA
* [ ] Support postgresql archive mode

##### Pending list

* Add parameters in dockerfile and scripts to support multiple version or configuration when building images
* Provide build image for extension build
* Podman stop and systemd conflict: cannot safely shutdown in systemd startup

## 2. Getting started

```shell
# create container
podman create --name sample_pg \
    -p 5432:5432 \
    -v /home/server/pgdata:/pgdata \
    -v /home/server/pgdata_wal:/pgdata_wal \
    image_postgres:v17.0

# start container
podman start sample_pg

# view log
podman logs -f sample_pg

# stop container
podman stop -t 120 sample_pg

# remove container
podman rm sample_pg
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

* TODO specify parameters, mount required files

## 3. Build image(postgresql 17.0)

1. Download `postgresql-17.0.tar.bz2` file from postgresql website
2. Run builder
    * `podman build --no-cache --force-rm --squash-all -t image_postgres:v17.0 .`

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
