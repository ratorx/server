FROM syncthing/syncthing:latest

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 8384 || exit 1