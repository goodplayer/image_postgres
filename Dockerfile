#======================================
# Step1: build
FROM debian:12.7 AS build

# Custom parameters
ARG PG_SOURCE_FILE=postgresql-17.0.tar.bz2
ARG PG_SOURCE_EXTRACT_FOLDER=postgresql-17.0
ARG OLD_PG_SOURCE_FILE=postgresql-16.4.tar.bz2
ARG OLD_PG_SOURCE_EXTRACT_FOLDER=postgresql-16.4

# setup debian apt repository
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# update apt packages
RUN apt update && apt upgrade -y

#-------------------------------------

# install build dependencies
RUN apt install -y build-essential \
                llvm clang pkgconf bison flex \
                libicu-dev liblz4-dev \
                libzstd-dev libreadline-dev \
                libxslt-dev libossp-uuid-dev zlib1g-dev \
                libssl-dev

# copy postgresql sourcecode
COPY ${PG_SOURCE_FILE} /
# decompress sourcecode package
RUN tar xf ${PG_SOURCE_FILE} -C /
# compile postgresql
WORKDIR /${PG_SOURCE_EXTRACT_FOLDER}
RUN ./configure --prefix=/pg \
    --with-blocksize=16 \
    --with-segsize=4 \
    --with-wal-blocksize=16 \
    --with-llvm \
    --with-uuid=ossp \
    --with-libxml \
    --with-libxslt \
    --with-lz4 \
    --with-zstd \
    --with-ssl=openssl
RUN make -j
RUN make install
WORKDIR /${PG_SOURCE_EXTRACT_FOLDER}/contrib
RUN make -j
RUN make install

WORKDIR /
# copy old postgresql sourcecode
COPY ${OLD_PG_SOURCE_FILE} /
# decompress sourcecode package
RUN tar xf ${OLD_PG_SOURCE_FILE} -C /
# compile postgresql
WORKDIR /${OLD_PG_SOURCE_EXTRACT_FOLDER}
RUN ./configure --prefix=/pg_old \
    --with-blocksize=16 \
    --with-segsize=4 \
    --with-wal-blocksize=16 \
    --with-llvm \
    --with-uuid=ossp \
    --with-libxml \
    --with-libxslt \
    --with-lz4 \
    --with-zstd \
    --with-ssl=openssl
RUN make -j
RUN make install
WORKDIR /${OLD_PG_SOURCE_EXTRACT_FOLDER}/contrib
RUN make -j
RUN make install

#=======================================
# Step2: final image
FROM debian:12.7

# copy binary files from build image to current image
COPY --from=build /pg /pg
COPY --from=build /pg_old /pg_old

# setup debian apt repository
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# update apt packages
RUN apt update && apt upgrade -y

# install apt packages
RUN apt install -y libxml2 libicu72 libssl3 libreadline8 libxslt1.1 libllvm14 libossp-uuid16 sudo

# create user
RUN groupadd admin
RUN useradd -m -g admin admin
# for security reason, do not grant admin the sudo permission
#RUN usermod -a -G sudo admin
RUN usermod -a -G admin admin

# copy scripts
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY pgconf /pgconf
RUN chown -R admin: /pgconf

#=======================================
# Step3: entrypoint

# use sigint instead of default SIGTERM to stop the container fast
# refer to https://www.postgresql.org/docs/current/server-shutdown.html
STOPSIGNAL SIGINT

ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres", "17"]
