# syntax=docker/dockerfile:1

FROM golang:1.18-alpine AS is-builder

ENV PACKAGES curl make git libc-dev bash gcc linux-headers
ENV CGO_ENABLED=0
ENV GOOS=linux

RUN apk add --no-cache $PACKAGES

WORKDIR /downloads
RUN git clone https://github.com/cosmos/interchain-security.git

RUN cd interchain-security && git checkout sainoe/export-genesis && make install

FROM informalsystems/hermes:0.15.0 AS hermes-builder

FROM --platform=linux/amd64 debian:buster-slim
USER root
WORKDIR /root

RUN apt update && apt install -y jq vim procps

COPY --chown=0:0 --from=hermes-builder /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /usr/lib/x86_64-linux-gnu/libssl.so.1.1
COPY --chown=0:0 --from=hermes-builder /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1

COPY --from=is-builder /go/bin/interchain-security-pd /usr/local/bin/interchain-security-pd
COPY --from=is-builder /go/bin/interchain-security-cd /usr/local/bin/interchain-security-cd


COPY --from=hermes-builder /usr/bin/hermes /usr/local/bin/

RUN chmod +x /usr/local/bin/hermes /usr/local/bin/interchain-security-pd /usr/local/bin/interchain-security-cd

ADD  ./scripts ./scripts

EXPOSE 26658 26648

ENTRYPOINT [ "/bin/bash" ]

