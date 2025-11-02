ARG CORE_IMAGE_VERSION=v17.6
FROM goodplayer/image_postgres_builder_core:${CORE_IMAGE_VERSION}

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
COPY buildpkg /buildpkg
COPY buildscripts /buildscripts
RUN mkdir /extensions && cp /buildscripts/*.desc.json /extensions
RUN chmod +x /buildscripts/*.sh
WORKDIR /buildscripts
RUN pgimagetool buildext /pg/bin
WORKDIR /
