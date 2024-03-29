# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOCKER_NGSOLVE=1 \
    DOCKER_PYMOR=1 \
    OPENBLAS_NUM_THREADS=1 \
    GOTO_NUM_THREADS=1 \
    OMP_NUM_THREADS=1 \
    DEBIAN_FRONTEND=teletype \
    PETSC_DIR=/usr/local/petsc-32 \
    LD_LIBRARY_PATH=/usr/local/petsc-32/lib/ \
    BOOST_VERSION=1.74.0

# -dev packages should be kept as few as possible, and listed here with reasoning
# mpi-default-bin: mpi runtime for tests
# matplotlib/Qt backend: libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
#     libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 libxcb-util0
# fenics/petsc:
#         boost*
#         libsz2
#         libhdf5-mpi-dev
#         libeigen3-dev
# ngsolve: liboce-modeling11 liboce-ocaf11 libopengl0 \
#          libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4 libgsl23
# gmsh: libxcursor1 libxinerama1
# deal.II: libboost libtbb
# precice: libxml2
# dolfinx: libscotch-6.1
RUN MOUNT_CACHE \
    echo "deb http://deb.debian.org/debian/ bullseye contrib non-free" > /etc/apt/sources.list.d/bullseye-nonfree.list && \
    apt update && \
    ${APTINSTALL} libboost1.74-all-dev && \
    ${APTINSTALL} wget curl less \
        texlive-base xvfb gnupg ca-certificates \
        gcc g++ gfortran make dirmngr pandoc \
        swig cmake libopenblas-dev \
        aptitude bison flex ninja-build \
        xauth gsl-bin git-lfs \
        vim mpi-default-bin gosu sudo \
        liboce-modeling11 liboce-ocaf11 libopengl0 \
        libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4  \
        libhdf5-mpi-dev \
        libeigen3-dev \
        libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
          libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 libxcb-util1\
        libxcursor1 libxinerama1 \
        libxml2 libtbb2 \
        elfutils \
    libsz2  libptscotch-6.1 && \
    echo "alias ls='ls -h --color=auto'" >> /etc/bash.bashrc && \
    echo "alias ll='ls -lh'" >> /etc/bash.bashrc && \
    echo "source /usr/local/share/dolfin/dolfin.conf" >> /etc/bash.bashrc && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# openmpi wants to call gstack to get traces, which is not available on debian
# provide a wrapper with name that forwards calls to eu-stack instead
COPY gstack /usr/local/bin/

COPY --from=REGISTRY/pymor/petsc_pyPYVER:VERTAG /usr/local/ /usr/local/
COPY --from=REGISTRY/pymor/dealii_pyPYVER:VERTAG /usr/local/ /usr/local/
COPY --from=REGISTRY/pymor/ngsolve_pyPYVER:VERTAG /usr/local/ /usr/local/
COPY --from=REGISTRY/pymor/fenics_pyPYVER:VERTAG /usr/local/ /usr/local/
COPY --from=REGISTRY/pymor/precice_pyPYVER:VERTAG /usr/local/ /usr/local/
RUN rm -rf /usr/local/man
# COPY --from=REGISTRY/pymor/dolfinx_pyPYVER:VERTAG /usr/local/ /usr/local/

RUN MOUNT_CACHE \
    PIP_SELF_UPDATE && \
    PIP_CHECK && \
    ${PIP_INSTALL} /usr/local/tmp/pymor_dealii-*.whl && \
    ${PIP_INSTALL} pymor-oldest-supported-numpy==${PYMOR_OLDEST_NUMPY_VERSION} && \
    ldconfig && \
    python -c "import ngsolve" && \
    python -c "import pymor_dealii" && \
    python -c "import precice" && \
    python -c "from dolfin import cpp" && \
    # python -c "from dolfinx import *" && \
    pip install termtables python-dotenv # for pymor-info script
RUN MOUNT_CACHE \
  (find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null ) && \
  python -c "import ngsolve" && \
  python -c "import precice" && \
  python -c "import pymor_dealii" && \
    python -c "from dolfin import cpp"
    #   python -c "from dolfinx import *"

COPY pymor-info /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
COPY *.pip.conf /usr/local/share/

COPY --from=pymor/pypi-mirror_stable_pyPYVER:VERTAG /pymor/downloads/* /tmp/dependencies/
RUN MOUNT_CACHE \
    set -exu && (for pkg in /tmp/dependencies/* ; do pip install --no-deps --no-cache-dir ${pkg} && \
     rm ${pkg} ; done)

# from here on images are user facing, unset away from mounted cache
# empty cache home leads to a bunch of programs segfaulting
ENV CCACHE_DIR=/tmp/ccache \
    XDG_CACHE_HOME=/tmp/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["./.ci/gitlab/script.bash"]
