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
    echo 'APT::Default-Release "bullseye";' > /etc/apt/apt.conf.d/default-release && \
    echo "#deb http://deb.debian.org/debian bullseye-backports main contrib non-free" > /etc/apt/sources.list.d/bullseye-backports.list && \
    echo "deb http://deb.debian.org/debian/ bullseye contrib non-free" > /etc/apt/sources.list.d/bullseye-nonfree.list && \
    apt update && \
    apt-get install -q=100 -y --no-install-recommends libboost1.74-all-dev && \
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
    PIP_SELF_UPDATE && \
    PIP_CHECK && \
    pip install \
        flufl.lock \
        pymor-oldest-supported-numpy~=2021.1.0 \
        ply \
        pytest \
        scipy \
        six \
        subprocess32 \
        urllib3


# Environment variables
ENV PETSC_VERSION=3.16.3 \
    PETSC4PY_VERSION=3.16.1 \
    OPENBLAS_NUM_THREADS=1 \
    OPENBLAS_VERBOSE=0

# Install PETSc from source
RUN MOUNT_CACHE \
    nproc --ignore=1 && \
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
     make MAKE_ARGS && \
     make install

# By default use the 32-bit build of PETSc.
# these can not be moved, configure behaves differently when these are already in the env
ENV PETSC_DIR=/usr/local/petsc-32

RUN printenv > /usr/local/share/petsc.env
