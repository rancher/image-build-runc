ARG BCI_IMAGE=registry.suse.com/bci/bci-base:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.16.10b7
FROM ${BCI_IMAGE} as bci
FROM ${GO_IMAGE} as builder
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
ARG SRC="github.com/opencontainers/runc"
ARG TAG="v1.0.2"
ARG ARCH="amd64"
RUN git clone --depth=1 https://${SRC}.git $GOPATH/src/${PKG}
WORKDIR $GOPATH/src/${PKG}
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
RUN BUILDTAGS='seccomp selinux apparmor' make static
RUN go-assert-static.sh runc
RUN if [ "${ARCH}" != "s390x" ]; then \
    go-assert-boring.sh runc; \
    fi
RUN install -s runc /usr/local/bin
RUN runc --version

FROM bci
RUN zypper update -y && \
    zypper clean --all
COPY --from=builder /usr/local/bin/ /usr/local/bin/
