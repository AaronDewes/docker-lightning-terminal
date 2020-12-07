ARG VERSION=patch-1

FROM golang:1.15.5-alpine as builder

ARG VERSION

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Explicitly turn on the use of modules (until this becomes the default).
ENV GO111MODULE on

# Install dependencies and install/build lightning-terminal.
RUN apk add --no-cache --update alpine-sdk \
    git \
    make \
    curl \
    bash \
    binutils \
    tar \
    protobuf-dev \
    zip \
    nodejs \
    yarn \
    protoc \
&& git clone --branch $VERSION https://github.com/AaronDewes/lightning-terminal /go/src/github.com/lightninglabs/lightning-terminal\
&& cd /go/src/github.com/lightninglabs/lightning-terminal \
&& make install \
&& make go-install-cli

# Start a new, final image to reduce size.
FROM alpine as final

# Define a root volume for data persistence.
VOLUME /root/.lnd

# Expose lightning-terminal and lnd ports (server, rpc).
EXPOSE 8443 10009 9735

# Copy the binaries and entrypoint from the builder image.
COPY --from=builder /go/bin/litd /bin/
COPY --from=builder /go/bin/lncli /bin/
COPY --from=builder /go/bin/frcli /bin/
COPY --from=builder /go/bin/loop /bin/
COPY --from=builder /go/bin/pool /bin/

COPY entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint

# Add bash.
RUN apk add --no-cache \
    bash \
    jq \
    ca-certificates

# Specify the start command and entrypoint as the lightning-terminal daemon.
ENTRYPOINT ["/bin/entrypoint"]
