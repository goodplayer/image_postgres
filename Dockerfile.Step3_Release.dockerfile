ARG EXT_IMAGE_VERSION=v17.6
ARG OS_VERSION=13.1
FROM goodplayer/image_postgres_builder_ext:${EXT_IMAGE_VERSION} AS build

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

# copy init scripts
COPY init_scripts /tmp/init_scripts

#=======================================
# Final step for entrypoint

# use sigint instead of default SIGTERM to stop the container fast
# refer to https://www.postgresql.org/docs/current/server-shutdown.html
STOPSIGNAL SIGINT

ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres", "17"]
