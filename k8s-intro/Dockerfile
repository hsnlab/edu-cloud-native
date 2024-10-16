FROM golang:alpine AS builder

WORKDIR /
COPY *.go /
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -trimpath -o hello_server hello_server.go

# ##########################################################################
FROM alpine

RUN apk add --no-cache \
    bash \
    tar \
    curl \
    tcpdump
COPY --from=builder /hello_server /usr/bin/hello_server
EXPOSE 8080
ENTRYPOINT ["hello_server"]
