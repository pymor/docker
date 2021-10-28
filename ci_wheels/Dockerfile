# syntax = docker/dockerfile:experimental
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV WHEEL_VERSION=0.36.1 \
  WHEEL_PKGS="slycot mpi4py gmsh"

# libopenblas-dev cmake: needed for slycot
# mpi-default-dev: mpi4py
RUN MOUNT_CACHE apt update && \
  apt install -y unp \
      libopenblas-dev cmake \
      mpi-default-dev unzip


COPY build_*.sh /builder/
RUN MOUNT_CACHE \
  python -m pip install oldest-supported-numpy && \
  WHEELHOUSE=/wheelhouse /builder/build_wheels.sh && \
  echo "${WHEEL_PKGS}" > /wheelhouse/ci_wheels.list

FROM alpine:3.12

# for compat with general run_* makefile target
RUN apk add bash

COPY --from=builder /wheelhouse/* /wheelhouse/
