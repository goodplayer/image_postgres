#======================================
# Step1: build
FROM debian:12.7 AS build

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
#TODO use parameter to set sourcecode file
COPY postgresql-17.0.tar.bz2 /

# decompress sourcecode package
RUN tar xf postgresql-17.0.tar.bz2 -C /

# compile postgresql
#TODO use parameter to set sourcecode folder
WORKDIR /postgresql-17.0
#TODO use parameter to set install folder
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
#TODO use parameter to set sourcecode folder
WORKDIR /postgresql-17.0/contrib
RUN make -j
RUN make install

#=======================================
# Step2: final image
FROM debian:12.7

# copy binary files from build image to current image
COPY --from=build /pg /pg

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

ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres", "17"]
