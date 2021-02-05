FROM golang:alpine
RUN apk --no-cache add gcc g++
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
RUN GOOS=linux go build -o gh . && go test .

FROM alpine:latest
RUN apk --no-cache add netcat-openbsd
WORKDIR /app
COPY --from=0 /app/gh .

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 8080 || exit 1

ENTRYPOINT [ "./gh" ]
