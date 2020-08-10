UNAME_M = $(shell uname -m)
ARCH=
ifeq ($(UNAME_M), x86_64)
	ARCH=amd64
else
	ARCH=$(UNAME_M)
endif

SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/runc:$(TAG)-$(ARCH) .

.PHONY: image-push
image-push:
	docker push rancher/runc:$(TAG)-$(ARCH)

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/runc:$(TAG)-$(ARCH)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/runc:$(TAG)-$(ARCH)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/runc:$(TAG)-$(ARCH) \
		$(shell docker image inspect rancher/runc:$(TAG)-$(ARCH) | jq -r '.[] | .RepoDigests[0]')
