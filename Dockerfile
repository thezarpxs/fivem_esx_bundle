
# BASED ON THE spritsail/fivem IMAGE! HUGE THANKS!

ARG FIVEM_NUM=1971
ARG FIVEM_VER=1971-fbd5c11df14693e9be8a9b86b02689abfc790f69
ARG DATA_VER=2bde7889b4593d842e911827a33294211f40de93

FROM spritsail/alpine:3.10 as builder

ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output

RUN apk update && apk upgrade \
 && wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc \
            --exclude alpine/run --exclude alpine/sys \
 && mkdir -p /output/opt/cfx-server-data \
 && wget -O- http://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
        | tar xz --strip-components=1 -C opt/cfx-server-data \
    \
 && apk add nodejs npm \
 && apk -p $PWD add curl jq tini nodejs npm \
 && apk add git \
 && git clone -n https://github.com/tabarra/txAdmin.git \
 && cd txAdmin \
 && git checkout 6a442efdafa61dc26610c6d04b45f91f5ce24c24 \
 && npm i && cd .. \
 && mkdir fivem_run

ADD admins.json txAdmin/data
COPY default/ txAdmin/data/default
ADD server.cfg opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint
ADD run.sh fivem_run/run.sh

RUN mv txAdmin/data txAdmin/data.orig


RUN chmod +x /output/usr/bin/entrypoint /output/fivem_run/run.sh

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM
ARG DATA_VER


LABEL maintainer="Andruida <andruida@andruida.hu>" \
      org.label-schema.vendor="Andruida" \
      org.label-schema.name="FiveM" \
      org.label-schema.url="https://fivem.net" \
      org.label-schema.description="FiveM is a modification for Grand Theft Auto V enabling you to play multiplayer on customized dedicated servers. This image contains the txAdmin management interface too." \
      org.label-schema.version=${FIVEM_NUM} \
      hu.andruida.version.fivem=${FIVEM_VER} \
      hu.andruida.version.fivem_data=${DATA_VER}

COPY --from=builder /output/ /

WORKDIR /config

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
