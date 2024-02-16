VERSION = 3.1.0
ifneq ($VERSION, edge)
MAJOR_VERSION := $(shell awk -v OFS=. -F. '{print $$1,$$2}' <<< $(VERSION))
endif
OWNER = you54f
DISABLE_OPTIMIZATIONS = 0
OPENSSL_1_1_LEGACY ?= false
IMAGE = $(OWNER)/holy-build-box

.PHONY: build test tags push release

build:
	docker buildx build --progress=plain --platform "linux/amd64" --rm -t $(IMAGE):$(VERSION)-amd64-alpine -f Dockerfile-amd64 --pull --build-arg OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) --build-arg DISABLE_OPTIMIZATIONS=$(DISABLE_OPTIMIZATIONS) .
	docker buildx build --progress=plain --platform "linux/arm64" --rm -t $(IMAGE):$(VERSION)-arm64-alpine -f Dockerfile-arm64 --pull --build-arg OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) --build-arg DISABLE_OPTIMIZATIONS=$(DISABLE_OPTIMIZATIONS) .
build_amd:
	docker buildx build --progress=plain --platform "linux/amd64" --rm -t $(IMAGE):$(VERSION)-amd64-alpine -f Dockerfile-amd64 --pull --build-arg OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) --build-arg DISABLE_OPTIMIZATIONS=$(DISABLE_OPTIMIZATIONS) .
build_arm64:
	docker buildx build --progress=plain --platform "linux/arm64" --rm -t $(IMAGE):$(VERSION)-arm64-alpine -f Dockerfile-arm64 --pull --build-arg OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) --build-arg DISABLE_OPTIMIZATIONS=$(DISABLE_OPTIMIZATIONS) .
build_arm:
	docker buildx build --progress=plain --platform "linux/arm" --rm -t $(IMAGE):$(VERSION)-arm-alpine -f Dockerfile-arm --pull --build-arg OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) --build-arg DISABLE_OPTIMIZATIONS=$(DISABLE_OPTIMIZATIONS) .
build_i386:
	docker buildx build --progress=plain --platform "linux/i386" --rm -t $(IMAGE):$(VERSION)-i386-alpine -f Dockerfile-i386 --pull --build-arg OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) --build-arg DISABLE_OPTIMIZATIONS=$(DISABLE_OPTIMIZATIONS) .

test:
	docker run -it --platform "linux/arm64" --rm -e OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) -e SKIP_FINALIZE=1 -e DISABLE_OPTIMIZATIONS=1 -v $$(pwd)/image:/hbb_build:ro alpine:3.15 bash /hbb_build/build.sh
	docker run -it --platform "linux/amd64" --rm -e OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) -e SKIP_FINALIZE=1 -e DISABLE_OPTIMIZATIONS=1 -v $$(pwd)/image:/hbb_build:ro alpine:3.15 bash /hbb_build/build.sh
test_amd:
	docker run -it --platform "linux/amd64" --rm -e OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) -e SKIP_FINALIZE=1 -e DISABLE_OPTIMIZATIONS=1 -v $$(pwd)/image:/hbb_build:ro alpine:3.15 bash /hbb_build/build.sh
test_arm64:
	docker run -it --platform "linux/arm64" --rm -e OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) -e SKIP_FINALIZE=1 -e DISABLE_OPTIMIZATIONS=1 -v $$(pwd)/image:/hbb_build:ro alpine:3.15 bash /hbb_build/build.sh
test_arm:
	docker run -it --platform "linux/arm" --rm -e OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) -e SKIP_FINALIZE=1 -e DISABLE_OPTIMIZATIONS=1 -v $$(pwd)/image:/hbb_build:ro alpine:3.15 bash /hbb_build/build.sh
test_i386:
	docker run -it --platform "linux/i386" --rm -e OPENSSL_1_1_LEGACY=$(OPENSSL_1_1_LEGACY) -e SKIP_FINALIZE=1 -e DISABLE_OPTIMIZATIONS=1 -v $$(pwd)/image:/hbb_build:ro alpine:3.15 bash /hbb_build/build.sh

tags:
ifdef MAJOR_VERSION
	docker tag $(IMAGE):$(VERSION)-amd64-alpine $(IMAGE):$(MAJOR_VERSION)-amd64-alpine
	docker tag $(IMAGE):$(VERSION)-arm64-alpine $(IMAGE):$(MAJOR_VERSION)-arm64-alpine
	docker tag $(IMAGE):$(VERSION)-arm-alpine $(IMAGE):$(MAJOR_VERSION)-arm-alpine
	docker tag $(IMAGE):$(VERSION)-amd64-alpine $(IMAGE):latest-amd64-alpine
	docker tag $(IMAGE):$(VERSION)-arm64-alpine $(IMAGE):latest-amd64-alpine
	docker tag $(IMAGE):$(VERSION)-arm-alpine $(IMAGE):latest-arm-alpine
	docker tag $(IMAGE):$(VERSION)-i386-alpine $(IMAGE):latest-i386-alpine
endif
tags_amd:
ifdef MAJOR_VERSION
	docker tag $(IMAGE):$(VERSION)-amd64-alpine $(IMAGE):$(MAJOR_VERSION)-amd64-alpine
	docker tag $(IMAGE):$(VERSION)-amd64-alpine $(IMAGE):latest-amd64-alpine
endif
tags_arm64:
ifdef MAJOR_VERSION
	docker tag $(IMAGE):$(VERSION)-arm64-alpine $(IMAGE):$(MAJOR_VERSION)-arm64-alpine
	docker tag $(IMAGE):$(VERSION)-arm64-alpine $(IMAGE):latest-arm64-alpine
endif
tags_arm:
ifdef MAJOR_VERSION
	docker tag $(IMAGE):$(VERSION)-arm-alpine $(IMAGE):$(MAJOR_VERSION)-arm-alpine
	docker tag $(IMAGE):$(VERSION)-arm-alpine $(IMAGE):latest-arm-alpine
endif
tags_i386:
ifdef MAJOR_VERSION
	docker tag $(IMAGE):$(VERSION)-i386-alpine $(IMAGE):$(MAJOR_VERSION)-i386-alpine
	docker tag $(IMAGE):$(VERSION)-i386-alpine $(IMAGE):latest-i386-alpine
endif

push: tags
	docker push $(IMAGE):$(VERSION)-amd64-alpine
	docker push $(IMAGE):$(VERSION)-arm64-alpine
	docker push $(IMAGE):$(VERSION)-arm-alpine
	docker push $(IMAGE):$(VERSION)-arm-alpine
ifdef MAJOR_VERSION
	docker push $(IMAGE):$(MAJOR_VERSION)-amd64-alpine
	docker push $(IMAGE):$(MAJOR_VERSION)-arm64-alpine
	docker push $(IMAGE):$(MAJOR_VERSION)-arm-alpine
	docker push $(IMAGE):$(MAJOR_VERSION)-arm-alpine
	docker push $(IMAGE):latest-amd64-alpine
	docker push $(IMAGE):latest-arm64-alpine
	docker push $(IMAGE):latest-arm-alpine
	docker push $(IMAGE):latest-arm-alpine
endif
push_amd: tags_amd
	docker push $(IMAGE):$(VERSION)-amd64-alpine
ifdef MAJOR_VERSION
	docker push $(IMAGE):$(MAJOR_VERSION)-amd64-alpine
	docker push $(IMAGE):latest-amd64-alpine
endif
push_arm64: tags_arm64
	docker push $(IMAGE):$(VERSION)-arm64-alpine
ifdef MAJOR_VERSION
	docker push $(IMAGE):$(MAJOR_VERSION)-arm64-alpine
	docker push $(IMAGE):latest-arm64-alpine
endif
push_arm: tags_arm
	docker push $(IMAGE):$(VERSION)-arm-alpine
ifdef MAJOR_VERSION
	docker push $(IMAGE):$(MAJOR_VERSION)-arm-alpine
	docker push $(IMAGE):latest-arm-alpine
endif
push_i386: tags_arm
	docker push $(IMAGE):$(VERSION)-i386-alpine
ifdef MAJOR_VERSION
	docker push $(IMAGE):$(MAJOR_VERSION)-i386-alpine
	docker push $(IMAGE):latest-i386-alpine
endif

release: push
	docker manifest create $(IMAGE):$(VERSION)-alpine $(IMAGE):$(VERSION)-amd64 $(IMAGE):$(VERSION)-arm64-alpine (IMAGE):$(VERSION)-arm-alpine (IMAGE):$(VERSION)-i386-alpine
ifdef MAJOR_VERSION
	docker manifest create $(IMAGE):$(MAJOR_VERSION)-alpine $(IMAGE):$(MAJOR_VERSION)-amd64-alpine $(IMAGE):$(MAJOR_VERSION)-arm64-alpine $(IMAGE):$(MAJOR_VERSION)-arm-alpine $(IMAGE):$(MAJOR_VERSION)-i386-alpine
	docker manifest create $(IMAGE):latest $(IMAGE):latest-amd64-alpine $(IMAGE):latest-arm64-alpine $(IMAGE):latest-arm-alpine $(IMAGE):latest-i386-alpine 
	docker manifest push $(IMAGE):$(MAJOR_VERSION)-alpine
endif
	docker manifest push $(IMAGE):$(VERSION)-alpine
	docker manifest push $(IMAGE):latest-alpine
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
