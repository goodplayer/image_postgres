#======================================
ARG OS_VERSION=13.0
# Step1: build
FROM debian:${OS_VERSION} AS build

# Custom parameters
ARG PG_SOURCE_FILE=postgresql-17.6.tar.bz2
ARG PG_SOURCE_EXTRACT_FOLDER=postgresql-17.6

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
                libxslt1-dev libossp-uuid-dev zlib1g-dev \
                libssl-dev \
                unzip wget curl

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

# install build tool
WORKDIR /
COPY buildtool /buildtool
RUN chmod +x /buildtool/prepare.sh
WORKDIR /buildtool
RUN ./prepare.sh

WORKDIR /
# install go compiler for pg image tool
RUN apt install golang -y
#RUN ln -s /usr/lib/go-1.24/bin/go /usr/bin/go
# copy pg image tool sources && configure go compile env
COPY pg_image_tool /pg_image_tool
RUN chmod +x /pg_image_tool/init_go_env.sh && /pg_image_tool/init_go_env.sh
# compile pg image tool
RUN cd /pg_image_tool && go get && go build && /pg_image_tool/pgimagetool
# copy pg image tool to path
RUN cp /pg_image_tool/pgimagetool /usr/bin/pgimagetool

WORKDIR /
# copy buildscripts and run
COPY buildscripts /buildscripts
RUN mkdir /extensions && cp /buildscripts/*.desc.json /extensions
RUN chmod +x /buildscripts/*.sh
WORKDIR /buildscripts
RUN pgimagetool buildext /pg/bin
WORKDIR /

#=======================================
# Step2: final image
FROM debian:${OS_VERSION}
WORKDIR /

# copy binary files from build image to current image
COPY --from=build /pg /pg
COPY --from=build /usr/bin/pgimagetool /usr/bin/pgimagetool
COPY --from=build /extensions /extensions

# setup debian apt repository
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# update apt packages
RUN apt update && apt upgrade -y

# install apt packages
RUN apt install -y libxml2 libicu76 libssl3 libreadline8 libxslt1.1 libllvm19 libossp-uuid16 sudo

# install plugin dependencies
RUN mkdir /buildscripts
COPY --from=build /buildscripts /buildscripts
WORKDIR /buildscripts
RUN pgimagetool install_runtime_deps
RUN rm -rf /buildscripts
WORKDIR /

# create user
RUN groupadd -g 30000 admin
RUN useradd -u 30000 -m -g admin admin
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
