# EXPERIMENTAL_SYNTAX

FROM pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

WORKDIR /tmp

COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/mpi4py*.whl /tmp/

ENV DOLFINX_VERSION="main" \
  PETSC_ARCH= \
  PETSC_DIR=/usr/local/petsc-32 \
  PKG_CONFIG_PATH=/usr/local/petsc-32/lib/pkgconfig:${PKG_CONFIG_PATH}

RUN MOUNT_CACHE \
  apt update \
  && ${APTINSTALL} libptscotch-dev ninja-build \
  && wget -O /tmp/cmake.sh https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-x86_64.sh \
  && bash /tmp/cmake.sh --skip-license --prefix=/usr/local \
  && cmake --version \
  && PIP_SELF_UPDATE \
  && PIP_CHECK \
  && ${PIP_INSTALL}  numba /tmp/mpi4py* pybind11==${PYBIND11_VERSION} pymor-oldest-supported-numpy~=2021.1.0 \
  && ${PIP_INSTALL} --no-deps petsc4py==${PETSC4PY_VERSION} \
  && python -c "import petsc4py"

COPY modules /src/modules
RUN cd /src/modules \
  && export PYBIND11_ROOT=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))") \
  && mkdir /src/modules/basix/build \
  && cd /src/modules/basix/build \
  && cmake -B /src/modules/basix/build -DCMAKE_BUILD_TYPE=Release -S /src/modules/basix/ -DPYTHON_INTERPRETER=/usr/local/bin/python3 \
  -DDOWNLOAD_XTENSOR_LIBS=On \
  && cmake --build /src/modules/basix/build -- MAKE_ARGS \
  && cmake --install /src/modules/basix/build \
  && pip install /src/modules/basix/python \
  && (for i in fiat ufl ffcx ; do cd /src/modules/$i &&  ${PIP_INSTALL} . ;  done)


RUN MOUNT_CACHE \
  mkdir /src/modules/dolfinx/build \
  && cd /src/modules/dolfinx/build \
  && cmake -G Ninja \
  -DCMAKE_INSTALL_PREFIX=/usr/local/ \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_INTERPRETER=/usr/local/bin/python3 \
  ../cpp \
  && ninja install \
  && cd ../python \
  && ${PIP_INSTALL} install . \
  && ldconfig \
  && rm -rf /src \
  && printenv >> /usr/local/share/dolfinx.env

# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
# RUN apt-get update && apt-get -y install xvfb
# COPY demo_auto-adaptive_poisson.py /tmp/poisson_test/
# RUN /bin/bash -l -c "cd /tmp/poisson_test && \
#     time xvfb-run python demo_auto-adaptive_poisson.py && \
#     rm -r /tmp/poisson_test"

RUN MOUNT_CACHE \
  python -c "import dolfinx" \
  && rm -rf /usr/local/man
