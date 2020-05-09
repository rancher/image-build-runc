SEVERITIES = HIGH,CRITICAL

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t ranchertest/runc:$(TAG) .

.PHONY: image-push
image-push:
	docker push ranchertest/runc:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed ranchertest/runc:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect ranchertest/runc:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ranchertest/runc:$(TAG) \
		$(shell docker image inspect ranchertest/runc:$(TAG) | jq -r '.[] | .RepoDigests[0]')
