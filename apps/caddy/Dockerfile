FROM caddy:builder AS builder

RUN apk --no-cache add jq

RUN xcaddy build --with github.com/mholt/caddy-l4

# Build caddy config
COPY Caddyfile l4.json ./
RUN caddy adapt > http.json
RUN jq -s '.[0] * .[1]' l4.json http.json > caddy.json

FROM caddy:latest

# Setup prod image
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /usr/bin/caddy.json /etc/caddy/caddy.json

ENTRYPOINT [ "caddy", "run", "--config", "/etc/caddy/caddy.json" ]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 80 || exit 1