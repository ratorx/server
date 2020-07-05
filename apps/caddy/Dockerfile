FROM caddy:latest

RUN mkdir /certs

COPY Caddyfile /etc/caddy/Caddyfile

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 80 || exit 1