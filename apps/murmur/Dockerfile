FROM alpine:latest

EXPOSE 64738/tcp 64738/udp

RUN mkdir /data /config

RUN apk --no-cache add \
  openssl \
  murmur

# Add config file
COPY init.sh .
COPY murmur.ini /config

ENTRYPOINT ["/init.sh", "/config/murmur.ini"]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -uz localhost 64738 || exit 1
