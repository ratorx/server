#! /bin/sh

chown -R murmur:murmur /data/db

exec "$@"
