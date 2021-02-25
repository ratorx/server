FROM alpine:latest

EXPOSE 64738/tcp 64738/udp

RUN mkdir /data /config /data/cache

RUN apk --no-cache add \
  openssl \
  murmur

COPY entrypoint.sh /bin
COPY murmur.ini /config

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -uz localhost 64738 || exit 1

VOLUME /data/cache

ENTRYPOINT ["/bin/entrypoint.sh", "/usr/bin/murmurd", "-fg", "-ini", "/config/murmur.ini"]