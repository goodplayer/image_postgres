# Postgres Container

## 1. Features

* [x] Postgres container with contrib extensions
* [x] Supporting version specific data folder for major version upgrading
* [ ] Supporting auto-upgrade at container startup with recent two postgres versions(latest and one previous)
* [ ] Supporting customizing postgres configuration
    * Mapping configure files: TODO
* [ ] Supporting customizing data folder
    * Mapping folder: TODO
* [x] Supporting starting container from both fresh new and existing instance
* [x] Supporting safe container stop
* [ ] Supporting customize extension
* [ ] Supporting customize initdb parameters
* [ ] Supporting both primary and standby instance image
* [ ] Supporting ssl configuration & custom CA

##### Pending list

* Add parameters in dockerfile and scripts to support multiple version or configuration when building images
* Provide build image for extension build

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

### Customization

#### 1. Customize debian repository

Edit `debian.sources` file before building the image

## A. References

* Offical postgres image: [https://github.com/docker-library/postgres](https://github.com/docker-library/postgres)
