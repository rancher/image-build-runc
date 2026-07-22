ARG GO_IMAGE=rancher/hardened-build-base:v1.25.12b1
FROM ${GO_IMAGE} AS builder
# setup required packages
RUN set -x && \
    apk --no-cache add \
    file \
    gcc \
    git \
    libselinux-dev \
    libseccomp-dev \
    libseccomp-static \
    make
# setup the build
ARG PKG="github.com/opencontainers/runc"
ARG TAG="v1.4.1"
ARG TARGETARCH="amd64"
RUN git clone --depth=1 https://${PKG}.git $GOPATH/src/${PKG}
WORKDIR $GOPATH/src/${PKG}
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
COPY go-mod-overrides ./go-mod-overrides
RUN go-mod-overrides.sh ./go-mod-overrides
RUN BUILDTAGS='seccomp selinux apparmor' GOEXPERIMENT='boringcrypto' make static
RUN go-assert-static.sh runc
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
    	go-assert-boring.sh runc; \
    fi
RUN install -s runc /usr/local/bin
RUN runc --version

FROM scratch
LABEL org.opencontainers.image.url="https://hub.docker.com/r/rancher/hardened-runc"
LABEL org.opencontainers.image.source="https://github.com/rancher/image-build-runc"
COPY --from=builder /usr/local/bin/ /usr/local/bin/
