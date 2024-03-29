FROM REGISTRY/pymor/dealii_pyPYVER:VERTAG
MAINTAINER René Fritze <rene.fritze@wwu.de>

COPY --from=REGISTRY/pymor/petsc_pyPYVER:VERTAG /usr/local/ /usr/local/
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/mpi4py*.whl /tmp/

ENV PRECICE_BUILD_TYPE=Release \
    PRECICE_PREFIX=/usr/local \
    PRECICE_VERSION=v2.5.0 \
    PETSC_DIR=/usr/local/petsc-32 \
    LD_LIBRARY_PATH=/usr/local/petsc-32/lib/

WORKDIR /tmp

# need to install pyprecice w/o isolation or else get too new numpy
RUN MOUNT_CACHE \
  PIP_SELF_UPDATE \
  && ${PIP_INSTALL} /tmp/mpi4py*whl \
  && git clone https://github.com/precice/precice /tmp/precice \
                  && cd /tmp/precice \
                  && git checkout ${PRECICE_VERSION} \
                  && mkdir /tmp/precice/build \
  && apt update \
  && ${APTINSTALL} build-essential ca-certificates cmake ninja-build \
    libxml2-dev libeigen3-dev libboost1.74-all-dev \
  && cd /tmp/precice/build \
  && ${PIP_INSTALL} pymor-oldest-supported-numpy==${PYMOR_OLDEST_NUMPY_VERSION} \
  && cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${PRECICE_PREFIX} \
      -DCMAKE_BUILD_TYPE=${PRECICE_BUILD_TYPE} \
      -DPython3_ROOT_DIR=/usr/local/ \
      -DPython3_EXECUTABLE=/usr/local/bin/python3 \
      -DPython3_COMPILER=/usr/local/bin/python3 \
      -DPRECICE_MPICommunication=ON \
      -DPRECICE_PETScMapping=ON \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DBUILD_SHARED_LIBS=ON \
    && make MAKE_ARGS \
    && make install \
    && cd /tmp \
    && rm -rf /tmp/precice \
  && git clone https://github.com/precice/dealii-adapter ${PRECICE_PREFIX}/src/dealii-adapter \
  && cd ${PRECICE_PREFIX}/src/dealii-adapter \
  && cmake . \
  && make \
  && ldconfig \
  && ${PIP_INSTALL} pkgconfig cython \
  && ${PIP_INSTALL} --no-build-isolation pyprecice \
  && python -c "import precice" \
  && printenv >> /usr/local/share/precice.env
