ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.16.4b7
FROM ${UBI_IMAGE} as ubi
FROM ${GO_IMAGE} as builder
# setup required packages
RUN set -x \
 && apk --no-cache add \
    file \
    gcc \
    git \
    libselinux-dev \
    libseccomp-dev \
    libseccomp-static \
    make
# setup the build
ARG PKG="github.com/opencontainers/runc"
ARG SRC="github.com/opencontainers/runc"
ARG TAG="v1.0.0-rc95"
RUN git clone --depth=1 https://${SRC}.git $GOPATH/src/${PKG}
WORKDIR $GOPATH/src/${PKG}
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
RUN BUILDTAGS='seccomp selinux apparmor' make static
RUN go-assert-static.sh runc
RUN go-assert-boring.sh runc
RUN install -s runc /usr/local/bin
RUN runc --version

FROM ubi
RUN microdnf update -y && \
    rm -rf /var/cache/yum
COPY --from=builder /usr/local/bin/ /usr/local/bin/
