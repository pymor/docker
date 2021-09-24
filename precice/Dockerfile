FROM REGISTRY/pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV PRECICE_BUILD_TYPE=Release \
    PRECICE_PREFIX=/usr/local \
    PRECICE_VERSION=v2.2.1 \
    OPENFOAM_DIR=/usr/local/src/openfoam

SHELL ["/bin/bash", "-c"]
WORKDIR /tmp
RUN  MOUNT_CACHE \
  git clone https://github.com/precice/precice.git /tmp/precice && \
                  cd /tmp/precice && \
                  git checkout ${PRECICE_VERSION} && \
                  mkdir /tmp/precice/build \
  && apt update \
  && apt install -y libxml2-dev \
  && cd /tmp/precice/build \
  && cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${PRECICE_PREFIX} \
      -DCMAKE_BUILD_TYPE=${PRECICE_BUILD_TYPE} \
      -DPRECICE_MPICommunication=ON \
      -DPRECICE_PETScMapping=ON \
      -DPYTHON_EXECUTABLE:FILEPATH=$(which python) \
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
      -DBUILD_SHARED_LIBS=ON \
    && make -j ${MAKE_PROCS} \
    && make install

COPY --from=REGISTRY/pymor/openfoam_pyPYVER:VERTAG ${OPENFOAM_DIR} /usr/local/src/openfoam

RUN  git clone https://github.com/precice/openfoam-adapter ${PRECICE_PREFIX}/src/adapter \
  && source ${OPENFOAM_DIR}/etc/bashrc \
  && cd ${PRECICE_PREFIX}/src/adapter \
  && ./Allwmake -j -s -q -l
