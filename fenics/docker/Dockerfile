FROM REGISTRY/pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV FENICS_BUILD_TYPE=Release \
    FENICS_PREFIX=/usr/local \
    FENICS_VERSION=2019.1.0 \
    FENICS_PYTHON=python \
    DOLFIN_VERSION="fix_gcc_10" \
    MSHR_VERSION="2019.1.0" \
    PYPI_FENICS_VERSION=">=2019.1.0,<2019.2.0" \
    FENICS_PYTHON=python
WORKDIR /tmp

COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/mpi4py*.whl /tmp/
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/petsc4py*.whl /tmp/
# Install Python environment
# petsc4py would install a separate petsc copy w/o --no-deps
RUN MOUNT_CACHE \
    PIP_SELF_UPDATE && \
    PIP_CHECK && \
    ${PIP_INSTALL} pymor-oldest-supported-numpy==${PYMOR_OLDEST_NUMPY_VERSION} && \
    ${PIP_INSTALL} ply && \
    ${PIP_INSTALL} pytest && \
    ${PIP_INSTALL} scipy && \
    ${PIP_INSTALL} six && \
    ${PIP_INSTALL} pybind11==${PYBIND11_VERSION} && \
    ${PIP_INSTALL} sympy==1.5.1 && \
    ${PIP_INSTALL} "matplotlib<3.6.0" && \
    ${PIP_INSTALL} /tmp/mpi4py*.whl && \
    ${PIP_INSTALL} /tmp/*.whl && \
    apt update \
    && ${APTINSTALL} build-essential ca-certificates  libboost1.74-all-dev

# Our helper scripts
WORKDIR $FENICS_HOME
COPY fenics.env.conf $FENICS_HOME/fenics.env.conf

RUN PYTHON_SITE_DIR=$(python -c "import site; print(site.getsitepackages()[0])") && \
    PYTHON_VERSION=$(python -c 'import sys; print(str(sys.version_info[0]) + "." + str(sys.version_info[1]))') && \
    echo "$FENICS_HOME/local/lib/python$PYTHON_VERSION/site-packages" >> $PYTHON_SITE_DIR/fenics-user.pth

WORKDIR /tmp
RUN MOUNT_CACHE ${PIP_INSTALL} "fenics${PYPI_FENICS_VERSION}" && \
    git clone https://github.com/renefritze/legacy-dolfin dolfin && \
                  cd dolfin && \
                  mkdir build && \
                  cd build && \
                  export PYBIND11_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))") && \
                  export pybind11_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))") && \
                  cmake ../ \
                    -DDOLFIN_ENABLE_MPI=on \
                    -DDOLFIN_ENABLE_PETSC=on \
                    -DDOLFIN_ENABLE_SCOTCH=on \
                    -DPYTHON_INTERPRETER=/usr/local/bin/python3 \
                    -Dpybind11_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))") \
                    -DPYBIND11_DIR=$(python3 -c "import sysconfig; print(sysconfig.get_path('purelib'))") \
                    -DDOLFIN_ENABLE_HDF5=on && \
                  make MAKE_ARGS && \
                  make install && \
                  mv /usr/local/share/dolfin/demo /tmp/demo && \
                  mkdir -p /usr/local/share/dolfin/demo && \
                  mv /tmp/demo /usr/local/share/dolfin/demo/cpp && \
                  cd ../python && \
                  ${PIP_INSTALL} . && \
                  cd demo && \
                  python3 generate-demo-files.py && \
                  mkdir -p /usr/local/share/dolfin/demo/python && \
                  cp -r documented /usr/local/share/dolfin/demo/python && \
                  cp -r undocumented /usr/local/share/dolfin/demo/python && \
                  cd /tmp/ && \
                  git clone https://bitbucket.org/fenics-project/mshr.git && \
                  cd mshr && \
                  git checkout ${MSHR_VERSION} && \
                  mkdir build && \
                  cd build && \
                  cmake ../ && \
                  make MAKE_ARGS && \
                  make install && \
                  ${PIP_INSTALL} /tmp/dolfin/python && \
                  ${PIP_INSTALL} /tmp/mshr/python && \
                  rm -rf /tmp/*

# Install fenics as root user into /usr/local then remove the fenics-* scripts
# the fenics.env.conf file and the unnecessary /home/fenics/local directory as
# the user does not need them in the stable image!
RUN /bin/bash -c "cp -r /usr/local/share/dolfin/demo $FENICS_HOME/demo && \
                  rm -rf /home/fenics/local && \
                  rm -rf $FENICS_HOME/bin && \
                  echo '' >> $FENICS_HOME/.profile && \
                  printenv >> /usr/local/share/fenics.env"

# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
COPY demo_auto-adaptive_poisson.py /tmp/poisson_test/
RUN apt-get update && apt-get -y install xvfb && \
    cd /tmp/poisson_test && \
    python3 -c "import mshr" && \
    xvfb-run -a python demo_auto-adaptive_poisson.py && \
    rm -r /tmp/poisson_test && \
    apt remove -y xvfb && \
    apt autoremove -y && \
    rm -rf /var/lib/apt
