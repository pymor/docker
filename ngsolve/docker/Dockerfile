# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

RUN MOUNT_CACHE \
    apt-get update && \
    apt-get -y install libxmu-dev tk-dev tcl-dev cmake git g++ \
    libglu1-mesa-dev ccache openssh-client openmpi-bin libopenmpi-dev \
    liboce-ocaf-dev libsuitesparse-dev python3-tk
ENV PATH="/opt/netgen/bin:${PATH}" \
    NGSOLVE_VERSION=v6.2.2104 \
    NGSOLVE_SRC_DIR=/root/src/ngsolve_src \
    NGSOLVE_BUILD_DIR=/root/src/ngsolve_build \
    PETSC_DIR=/usr/local/petsc-32
ENV MUMPS_DIR=${PETSC_DIR}

COPY --from=REGISTRY/pymor/petsc_pyPYVER:VERTAG ${PETSC_DIR} ${PETSC_DIR}

RUN MOUNT_CACHE \
    ${PIP_INSTALL} sphinx_rtd_theme pybind11_stubgen pybind11==${PYBIND11_VERSION} pymor-oldest-supported-numpy~=2021.1.0 && \
    git clone https://github.com/NGSolve/ngsolve.git ${NGSOLVE_SRC_DIR} && \
    cd ${NGSOLVE_SRC_DIR} && \
    git checkout ${NGSOLVE_VERSION} && \
    cd ${NGSOLVE_SRC_DIR}  && \
    git submodule update --init --recursive && \
    mkdir -p ${NGSOLVE_BUILD_DIR} && \
    cd ${NGSOLVE_BUILD_DIR} && \
    cmake ${NGSOLVE_SRC_DIR} \
    -DUSE_NATIVE_ARCH=OFF \
    -DUSE_OCC=ON \
    -DUSE_MPI=OFF \
    -DUSE_HYPRE=OFF \
    -DUSE_MUMPS=OFF \
    -DOpenGL_GL_PREFERENCE=GLVND \
    -DUSE_CCACHE=ON \
    -DUSE_MKL=OFF \
    -DUSE_UMFPACK=ON \
    -DINSTALL_PROFILES=OFF \
    -DENABLE_UNIT_TESTS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DNG_INSTALL_DIR_LIB=lib/netgen \
    -DNG_INSTALL_DIR_INCLUDE=include/netgen \
    -DCMAKE_INSTALL_PREFIX=/usr/local && \
    cmake --build ${NGSOLVE_BUILD_DIR} -- MAKE_ARGS && \
    cmake --install ${NGSOLVE_BUILD_DIR} && \
    find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null ; \
    rm -rf ${NGSOLVE_BUILD_DIR} ${NGSOLVE_SRC_DIR} && \
    printenv >> /usr/local/share/ngsolve.env
RUN python -c "import ngsolve"
