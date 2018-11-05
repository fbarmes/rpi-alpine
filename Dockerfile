#-------------------------------------------------------------------------------
# fbarmes/rpi-alpine image
#-------------------------------------------------------------------------------


#-- Base image
ARG ALPINE_VERSION=3.8
FROM arm32v6/alpine:${ALPINE_VERSION}

#-- add qemu emulator to allow cross platform build and run
COPY bin/qemu-arm-static /usr/bin/qemu-arm-static
