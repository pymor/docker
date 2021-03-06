# EXPERIMENTAL_SYNTAX

FROM REGISTRY/pymor/python_PYVER:VERTAG
MAINTAINER René Fritze <rene.fritze@wwu.de>

# Get Ubuntu updates
USER root
ENV FENICS_HOME /root/fenics
RUN mkdir ${FENICS_HOME} && touch $FENICS_HOME/.sudo_as_admin_successful

WORKDIR /tmp

# Non-Python utilities and libraries
RUN MOUNT_CACHE \
    echo 'APT::Default-Release "buster";' > /etc/apt/apt.conf.d/default-release && \
    echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list && \
    echo "deb http://deb.debian.org/debian/ buster contrib non-free" > /etc/apt/sources.list.d/buster-nonfree.list && \
    apt update && \
    apt-get install -q=100 -y --no-install-recommends -t buster-backports libboost1.71-all-dev && \
    apt-get -y install curl \
        bison \
        cmake \
        doxygen \
        flex \
        g++ \
        gfortran \
        git \
        git-lfs \
        libeigen3-dev \
        liblapack-dev \
        libopenmpi-dev \
        libopenblas-dev \
        libpcre3-dev \
        libhdf5-mpi-dev \
        libgmp-dev \
        libcln-dev \
        libmpfr-dev \
        openmpi-bin \
        nano \
        pkg-config \
        man \
        wget \
        ccache \
        git-lfs \
        bash-completion && \
    git lfs install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip install \
        flufl.lock \
        numpy \
        ply \
        pytest \
        scipy \
        six \
        subprocess32 \
        urllib3


# Environment variables
ENV PETSC_VERSION=3.14.3 \
    PETSC4PY_VERSION=3.14.1 \
    TRILINOS_VERSION=12.10.1 \
    OPENBLAS_NUM_THREADS=1 \
    OPENBLAS_VERBOSE=0 \
    PYBIND11_VERSION=2.6.1

# petsc4py would install a separate petsc copy w/o --no-deps
# Install PETSc from source
RUN MOUNT_CACHE \
    git clone -b release https://gitlab.com/petsc/petsc.git petsc && \
    cd petsc && \
    git checkout v${PETSC_VERSION} && \
    python ./configure --COPTFLAGS="-O2" \
                --CXXOPTFLAGS="-O2" \
                --FOPTFLAGS="-O2" \
                --with-debugging=0 \
                --download-blacs \
                --download-hypre \
                --download-metis \
                --download-mumps \
                --download-ptscotch \
                --download-scalapack \
                --download-spai \
                --download-suitesparse \
                --download-superlu \
                --prefix=/usr/local/petsc-32 && \
     make -j ${MAKE_PROCS} && \
     make install && \
  PETSC_DIR=/usr/local/petsc-32 PETSC_ARCH="" pip3 install --no-deps petsc4py==${PETSC4PY_VERSION} && \
  wget -nc --quiet https://github.com/pybind/pybind11/archive/v${PYBIND11_VERSION}.tar.gz && \
  tar -xf v${PYBIND11_VERSION}.tar.gz && \
  cd pybind11-${PYBIND11_VERSION} && \
  mkdir build && \
  cd build && \
  cmake -DPYBIND11_TEST=False ../ && \
  make -j ${MAKE_PROCS} && \
  make install && \
  rm -rf /tmp/*

# By default use the 32-bit build of PETSc.
# these can not be moved, configure behaves differently when these are already in the env
ENV PETSC_DIR=/usr/local/petsc-32

RUN printenv > /usr/local/share/petsc.env
