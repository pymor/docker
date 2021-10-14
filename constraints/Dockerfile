# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder_PYVER_VERTAG
# libopenblas-dev cmake: needed for slycot install (wheel building)
# mpi-default-dev: for mpi4py install/wheel
# until lxml wheel for 3.9 exists: libxslt1-dev libxml2-dev cython libjpeg-dev
RUN MOUNT_CACHE \
  pip install pypi-oldest-requirements==2020.4.2 cython && \
  apt update && \
  apt install -y libopenblas-dev mpi-default-dev make g++ gfortran cmake \
    libxslt1-dev libxml2-dev libjpeg-dev

COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /ci_wheels/
COPY requirements* /requirements/

COPY constraints.bash /usr/local/bin
RUN constraints.bash

FROM alpine:3.12

COPY --from=builder_PYVER_VERTAG /requirements/* /requirements/
