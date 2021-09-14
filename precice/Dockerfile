FROM REGISTRY/pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV PRECICE_BUILD_TYPE=Release \
    PRECICE_PREFIX=/usr/local \
    PRECICE_VERSION=v2.2.1

WORKDIR /tmp
RUN  MOUNT_CACHE \
  git clone https://github.com/precice/precice.git /tmp/precice && \
                  cd /tmp/precice && \
                  git checkout ${PRECICE_VERSION} && \
                  mkdir /tmp/precice/build
RUN  MOUNT_CACHE \
  apt update && apt install -y libxml2-dev
RUN  MOUNT_CACHE \
pip install numpy && \
                  cd /tmp/precice/build && \
                  cmake ../ \
                    -DCMAKE_INSTALL_PREFIX=${PRECICE_PREFIX} \
                    -DCMAKE_BUILD_TYPE=${PRECICE_BUILD_TYPE} \
                    -DPRECICE_MPICommunication=ON \
                    -DPRECICE_PETScMapping=ON \
                    -DPYTHON_EXECUTABLE:FILEPATH=$(which python) \
                    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
                    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
                  make -j ${MAKE_PROCS} && \
                  make install
RUN  MOUNT_CACHE \
  cd /tmp/precice/build \
  # && make test \
  && cd /tmp \
  && wget -q http://dl.openfoam.org/source/9 -O foam.tgz \
  && tar xfz foam.tgz

# COPY openfoam.bashrc /usr/local/src/
RUN MOUNT_CACHE \
cd /tmp/OpenFOAM-9-version-9 \
  && . etc/bashrc \
  && ./Allwmake
