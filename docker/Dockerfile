# Multi-stage build for security
FROM alpine:3.19 as builder

ARG MEMCACHED_VERSION=1.6.23

RUN apk add --no-cache \
    build-base \
    libevent-dev \
    openssl-dev \
    linux-headers \
    wget \
    ca-certificates

WORKDIR /tmp
RUN wget https://memcached.org/files/memcached-${MEMCACHED_VERSION}.tar.gz && \
    tar -xzf memcached-${MEMCACHED_VERSION}.tar.gz && \
    cd memcached-${MEMCACHED_VERSION} && \
    ./configure --prefix=/usr/local --enable-seccomp && \
    make && make install

FROM alpine:3.19

ARG MEMCACHED_MAX_MEMORY=128
ARG MEMCACHED_MAX_CONNECTIONS=1024
ARG MEMCACHED_PORT=11211
ARG MEMCACHED_THREADS=4
ARG MEMCACHED_MAX_ITEM_SIZE=1m

ENV MEMCACHED_MAX_MEMORY=${MEMCACHED_MAX_MEMORY} \
    MEMCACHED_MAX_CONNECTIONS=${MEMCACHED_MAX_CONNECTIONS} \
    MEMCACHED_PORT=${MEMCACHED_PORT} \
    MEMCACHED_THREADS=${MEMCACHED_THREADS} \
    MEMCACHED_MAX_ITEM_SIZE=${MEMCACHED_MAX_ITEM_SIZE}

RUN apk add --no-cache libevent ca-certificates && \
    rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/memcached /usr/local/bin/memcached

RUN addgroup -g 11211 -S memcache && \
    adduser -u 11211 -S -G memcache -s /sbin/nologin memcache

USER memcache
WORKDIR /home/memcache

EXPOSE ${MEMCACHED_PORT}

CMD memcached -m ${MEMCACHED_MAX_MEMORY} -c ${MEMCACHED_MAX_CONNECTIONS} -p ${MEMCACHED_PORT} -t ${MEMCACHED_THREADS} -I ${MEMCACHED_MAX_ITEM_SIZE} -u memcache -l 0.0.0.0 -vv
