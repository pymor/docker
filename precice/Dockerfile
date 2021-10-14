FROM REGISTRY/pymor/dealii_pyPYVER:VERTAG
MAINTAINER René Fritze <rene.fritze@wwu.de>

COPY --from=REGISTRY/pymor/petsc_pyPYVER:VERTAG /usr/local/ /usr/local/

ENV PRECICE_BUILD_TYPE=Release \
    PRECICE_PREFIX=/usr/local \
    PRECICE_VERSION=v2.2.1 \
    PETSC_DIR=/usr/local/petsc-32 \
    LD_LIBRARY_PATH=/usr/local/petsc-32/lib/

WORKDIR /tmp

RUN MOUNT_CACHE \
  echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list \
  && echo "deb http://deb.debian.org/debian/ buster contrib non-free" > /etc/apt/sources.list.d/buster-nonfree.list \
  && apt update \
  && ${APTINSTALL} -t buster-backports libboost1.71-all-dev \
  && git clone https://github.com/precice/precice.git /tmp/precice \
                  && cd /tmp/precice \
                  && git checkout ${PRECICE_VERSION} \
                  && mkdir /tmp/precice/build \
  && apt update \
  && apt install -y libxml2-dev libeigen3-dev \
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
    && make install \
    && cd /tmp \
    && rm -rf /tmp/precice \
  && git clone https://github.com/precice/dealii-adapter ${PRECICE_PREFIX}/src/dealii-adapter \
  && cd ${PRECICE_PREFIX}/src/dealii-adapter \
  && cmake . \
  && make \
  && ldconfig \
  && pip install pyprecice \
  && python -c "import precice"