SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t rancher/runc:$(TAG) .

.PHONY: image-push
image-push:
	docker push rancher/runc:$(TAG)

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed rancher/runc:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect rancher/runc:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create rancher/runc:$(TAG) \
		$(shell docker image inspect rancher/runc:$(TAG) | jq -r '.[] | .RepoDigests[0]')
