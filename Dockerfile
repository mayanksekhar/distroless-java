# syntax=docker/dockerfile:1
ARG BASE=gcr.io/distroless/cc-debian13:nonroot

FROM debian:13-slim AS fetch
ARG TARGETARCH
ARG ZULU=zulu25.38.201-ca-jre25.0.5.1
ARG SHA_AMD64=12277af4957cd249dc7aa50017ddde967a826fa48971b2411752fefe48e5ca8b
ARG SHA_ARM64=164c7293bc17dcd21e56f84778cacfe57501a66c7ad3265b7f9f36c4cd9ec1e0
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) A=x64;     S="$SHA_AMD64" ;; \
      arm64) A=aarch64; S="$SHA_ARM64" ;; \
      *) echo "unsupported arch $TARGETARCH"; exit 1 ;; \
    esac; \
    curl -fsSL -o /jre.tgz "https://cdn.azul.com/zulu/bin/${ZULU}-linux_${A}.tar.gz"; \
    echo "$S  /jre.tgz" | sha256sum -c -; \
    mkdir -p /opt/java; \
    tar -xzf /jre.tgz -C /opt/java --strip-components=1

FROM ${BASE}
COPY --from=fetch /opt/java /opt/java
ENV JAVA_HOME=/opt/java PATH=/opt/java/bin:/usr/local/bin:/usr/bin:/bin
ENTRYPOINT ["/opt/java/bin/java"]
CMD ["-version"]
