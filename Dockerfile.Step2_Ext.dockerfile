ARG CORE_IMAGE_VERSION=v17.6
FROM goodplayer/image_postgres_builder_core:${CORE_IMAGE_VERSION}

WORKDIR /
# copy buildscripts and run
COPY buildscripts /buildscripts
RUN mkdir /extensions && cp /buildscripts/*.desc.json /extensions
RUN chmod +x /buildscripts/*.sh
WORKDIR /buildscripts
RUN pgimagetool buildext /pg/bin
WORKDIR /
