# EXPERIMENTAL_SYNTAX

FROM pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOLFINX_VERSION="master"
WORKDIR /tmp

COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/mpi4py*.whl /tmp/

RUN MOUNT_CACHE \
  pip install numba /tmp/mpi4py* && \
  mkdir /src && cd /src && \
  (for i in basix fiat ufl ffcx dolfinx ; do git clone https://github.com/FEniCS/$i /src/$i ; done) && \
  (for i in basix fiat ufl ffcx dolfinx; do cd /src/$i && git checkout ${DOLFINX_VERSION} ; done) && \
  (for i in basix fiat ufl ffcx ; do cd /src/$i && pip install --no-cache-dir . ; done) && \
  apt update ; apt install -y ninja-build && \
  cd /src/dolfinx && \
  mkdir build && \
  cd build && \
  PETSC_ARCH=linux-gnu-real-32 cmake -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/usr/local/ \
    -DCMAKE_BUILD_TYPE=Release \
    ../cpp && \
  ninja install && \
  cd ../python && \
  PETSC_ARCH=linux-gnu-real-32 pip3 install . && \
  ldconfig && \
  rm -rf /src && \
  printenv >> /usr/local/share/dolfinx.env

# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
# RUN apt-get update && apt-get -y install xvfb
# COPY demo_auto-adaptive_poisson.py /tmp/poisson_test/
# RUN /bin/bash -l -c "cd /tmp/poisson_test && \
#     time xvfb-run python demo_auto-adaptive_poisson.py && \
#     rm -r /tmp/poisson_test"
