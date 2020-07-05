#! /bin/sh

chown -R murmur:murmur /data/db

exec murmurd -fg -ini "$1"
