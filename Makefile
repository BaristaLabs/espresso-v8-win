V8_VERSION ?= 8.4.371.19
IMAGE_PREFIX ?= baristalabs/espresso-v8

default: help

help:
	@echo 'Builds V8 ${V8_VERSION} binaries for embedding'
	@echo
	@echo 'Usage:'
	@echo '    make build-arm        Build ARM based binaries
	@echo '    make build-aarch64    Build ARM64 based binaries
	@echo '    make build-amd64      Build amd64 based binaries
	@echo

build-arm:
	docker build -f ./Dockerfile.v8 -t ${IMAGE_PREFIX}-armv7hf:${V8_VERSION} --build-arg BASE_IMAGE="balenalib/armv7hf-ubuntu:bionic" --build-arg V8_ARCH=arm --build-arg V8_VERSION=${V8_VERSION} -m 4g .
	docker create -ti --name dummy ${IMAGE_PREFIX}-armv7hf:${V8_VERSION} bash
	docker cp dummy:/build/v8/out/v8.release/* /bin/armv7hf/
	docker rm -f dummy

build-d8-aarch64:
	docker build -f ./Dockerfile.v8 -t ${IMAGE_PREFIX}-d8-aarch64:${V8_VERSION} --build-arg BASE_IMAGE="balenalib/aarch64-ubuntu:bionic" --build-arg V8_ARCH=aarch64 --build-arg V8_VERSION=${V8_VERSION} --build-arg V8_TARGET=py_mini_racer --build-arg TARGETPLATFORM=linux/aarch64 -m 4g .
	docker create -ti --name dummy ${IMAGE_PREFIX}-d8-aarch64:${V8_VERSION} bash
	docker cp dummy:/build/v8/out/v8.release/* /bin/aarch64/
	docker rm -f dummy

push-aarch64:
	docker push ${IMAGE_PREFIX}-aarch64:${V8_VERSION}
	docker tag ${IMAGE_PREFIX}-aarch64:${V8_VERSION} docker.io/${IMAGE_PREFIX}-aarch64:latest
	docker push docker.io/${IMAGE_PREFIX}-aarch64:latest

build-amd64:
	docker build -f ./Dockerfile.v8 -t ${IMAGE_PREFIX}-amd64:${V8_VERSION} --build-arg BASE_IMAGE="ubuntu:bionic" --build-arg V8_ARCH=x64 --build-arg V8_VERSION=${V8_VERSION} --build-arg TARGETPLATFORM=linux/amd64 -m 4g .
	docker create -ti --name dummy ${IMAGE_PREFIX}-amd64:${V8_VERSION} bash
	docker cp dummy:/build/v8/out/v8.release/ ./bin/amd64/
	docker rm -f dummy

.PHONY: help build-arm build-aarch64 build-amd64