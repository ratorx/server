#! /bin/sh

CERT_DIR="/data/cache"

if [ ! -f "$CERT_DIR"/key.pem ] || [ ! -f "$CERT_DIR"/cert.pem ]; then
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=AU/ST=Some-State/L=Some-Locality/O=Internet Widgits Pty Ltd/CN=murmur" \
    -keyout "$CERT_DIR"/key.pem -out "$CERT_DIR"/cert.pem
fi

chown -R murmur:murmur /data/db

exec "$@"
