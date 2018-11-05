#!/usr/bin/make -f

#-------------------------------------------------------------------------------
# Docker variables
#-------------------------------------------------------------------------------
DOCKER_IMAGE_NAME=fbarmes/rpi-alpine
DOCKER_IMAGE_VERSION=$(shell cat VERSION)

ALPINE_VERSION=3.8
QEMU_VERSION=3.0.0

#------------------------------------------------------------------------------
# script internals
#-------------------------------------------------------------------------------

#-- Absolute path to this Makefile
SCRIPT_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

#-- Url to Quemu
QEMU_URL=https://github.com/multiarch/qemu-user-static/releases/download/v${QEMU_VERSION}/qemu-arm-static.tar.gz

#-------------------------------------------------------------------------------
# Default target (all)
#-------------------------------------------------------------------------------
.PHONY: all
all: echo deps docker test

#-------------------------------------------------------------------------------
# clean target
#-------------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -rf ${SCRIPT_DIR}/bin

#-------------------------------------------------------------------------------
# echo
#-------------------------------------------------------------------------------
echo:
	@echo "DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME}"
	@echo "DOCKER_IMAGE_VERSION=${DOCKER_IMAGE_VERSION}"
	@echo "ALPINE_VERSION=${ALPINE_VERSION}"
	@echo "QEMU_VERSION=${QEMU_VERSION}"
	@echo "SCRIPT_DIR=${SCRIPT_DIR}"

#-------------------------------------------------------------------------------
# Gather dependencies
#-------------------------------------------------------------------------------
deps: bin/qemu-arm-static

#-------------------------------------------------------------------------------
# Build qemu
#-------------------------------------------------------------------------------
bin/qemu-arm-static:
	#-- build qemu binary
	mkdir -p ${SCRIPT_DIR}/bin
	wget ${QEMU_URL} --output-document ${SCRIPT_DIR}/bin/qemu-arm-static.tar.gz
	tar -zxvf ${SCRIPT_DIR}/bin/qemu-arm-static.tar.gz -C ${SCRIPT_DIR}/bin
	rm ${SCRIPT_DIR}/bin/qemu-arm-static.tar.gz

#-------------------------------------------------------------------------------
# Build docker image
#-------------------------------------------------------------------------------
docker:
	#-- register cpu emulation
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	#-- build image
	docker build \
	  --tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} \
	  --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
	  --file Dockerfile \
	  ${SCRIPT_DIR}

	#-- tag image as latest
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} ${DOCKER_IMAGE_NAME}:latest


#-------------------------------------------------------------------------------
# test image
#-------------------------------------------------------------------------------
test:
	docker run --rm ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} uname -a
