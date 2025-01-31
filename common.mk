SHELL := bash

TAG       := $(shell date -u +%Y%m%d.%H%M%S)
PLATFORMS := linux/amd64

GIT_UPSTREAM := $(shell git for-each-ref --format='%(upstream:short)' "$$(git symbolic-ref -q HEAD)")

ifndef IMAGE
$(error IMAGE not specified)
endif


.PHONY: all
all:
	$(MAKE) push
	@echo '$(IMAGE):$(TAG) ready'


.PHONY: build
build:
	docker buildx build --pull --load --platform='$(PLATFORMS)' --provenance=false -t '$(IMAGE):$(TAG)' .


.PHONY: push
push: build | git-check
	docker push '$(IMAGE):$(TAG)'


.PHONY: git-check
git-check:
	@if [[ '$(TAG)' = 'latest' ]]; then \
		$(MAKE) git-ensure-branch-main && \
		$(MAKE) git-ensure-working-tree-clean && \
		$(MAKE) git-ensure-index-clean && \
		$(MAKE) git-ensure-pushed ; \
	fi


.PHONY: git-ensure-branch-main
git-ensure-branch-main:
	[[ "$$(git symbolic-ref --quiet HEAD)" = 'refs/heads/main' ]]


.PHONY: git-ensure-working-tree-clean
git-ensure-working-tree-clean:
	git diff-files --quiet >/dev/null


.PHONY: git-ensure-index-clean
git-ensure-index-clean:
	git diff-index --quiet --cached HEAD -- >/dev/null


.PHONY: git-ensure-pushed
git-ensure-pushed:
	[[ -n '$(GIT_UPSTREAM)' ]]
	[[ "$$(git rev-list -n 1 $(GIT_UPSTREAM)..HEAD | wc -l)" -eq 0 ]]
