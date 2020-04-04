IMAGE := discourse/letter-avatars-nginx
TAG := $(shell date -u +%Y%m%d.%H%M%S)

.PHONY: default
default: push
	@printf "${IMAGE}:${TAG} ready\n"

.PHONY: push
push: build
	docker push ${IMAGE}:${TAG}

.PHONY: build
build:
	docker build --no-cache -t ${IMAGE}:${TAG} .
