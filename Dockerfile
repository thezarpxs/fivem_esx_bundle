ARG FIVEM_NUM=3322
ARG FIVEM_VER=3322-ed120d286d04b8e00bb75b6b89d5768886ac1e4f
ARG DATA_VER=dd38bd01923a0595ecccef8026f1310304d7b0e3
FROM wodby/mariadb:latest as builder

ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output
USER root
RUN wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc \
            --exclude alpine/run --exclude alpine/sys \
 && mkdir -p /output/opt/cfx-server-data \
 && wget -O- http://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
        | tar xz --strip-components=1 -C opt/cfx-server-data \
    \
 && apk -p $PWD add tini mariadb-dev tzdata

ADD server.cfg opt/cfx-server-data
ADD resources.tar opt/cfx-server-data
ADD database.sql opt/cfx-server-data
ADD entrypoint usr/bin/entrypoint
RUN chmod +x /output/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM
ARG DATA_VER

LABEL org.label-schema.name="FiveM" \
      org.label-schema.url="https://fivem.net" \
      org.label-schema.description="FiveM is a modification for Grand Theft Auto V enabling you to play multiplayer on customized dedicated servers." \
      org.label-schema.version=${FIVEM_NUM}

COPY --from=builder /output/ /



WORKDIR /config

RUN apk add --no-cache mariadb mariadb-client mariadb-server-utils pwgen tzdata && \
    rm -f /var/cache/apk/*

ADD files/run.sh /scripts/run.sh
RUN mkdir /docker-entrypoint-initdb.d && \
    mkdir /scripts/pre-exec.d && \
    mkdir /scripts/pre-init.d && \
    chmod -R 755 /scripts

EXPOSE 3306
EXPOSE 30120

VOLUME ["/var/lib/mysql"]

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
