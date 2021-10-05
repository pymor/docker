# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
ENV DEBIAN_FRONTEND=noninteractive
#for add-apt-repo
RUN MOUNT_CACHE \
    echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list && \
    echo "deb http://deb.debian.org/debian/ buster contrib non-free" > /etc/apt/sources.list.d/buster-nonfree.list && \
    apt update && \
    ${APTINSTALL} -t buster-backports libboost1.71-all-dev && \
    apt-get install -y software-properties-common \
    gfortran cmake g++\
    git \
    gsl-bin \
    libblas-dev \
    libbz2-dev \
    libgsl-dev \
    liblapack-dev \
    libnetcdf-c++4-dev \
    libnetcdf-cxx-legacy-dev \
    libnetcdf-dev \
    libarpack2-dev libgmsh-dev \
    liblapack-dev libmuparser-dev libmetis-dev libtbb-dev \
    ninja-build \
    numdiff \
    unzip \
    wget \
    zlib1g-dev \
    libopenmpi-dev \
# next line is necessary for xfvb/qt/gl demo to work, needed till imaged rebased on pymor/testing
    xauth x11-apps xvfb libgl1-mesa-dri libglu1-mesa \
    openmpi-bin gosu && \
    pip install numpy

ENV DEALII_VERSION=9.3.0
RUN MOUNT_CACHE \
    cd /tmp && git clone https://github.com/dealii/dealii.git dealii-${DEALII_VERSION}-src && \
    cd dealii-${DEALII_VERSION}-src && \
    git checkout v${DEALII_VERSION} && \
    mkdir build && cd build && \
    cmake -DDEAL_II_WITH_MPI=ON \
          -DDEAL_II_COMPONENT_EXAMPLES=OFF \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DCMAKE_BUILD_TYPE=Release \
          -DDEAL_II_ALLOW_BUNDLED=OFF \
          -GNinja \
          ../ && \
    ninja -j ${MAKE_PROCS} && \
    ninja -j 1 install && \
    find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null ; \
    cd / && rm -rf /tmp/deal* && \
    cd /tmp && git clone --recurse-submodules --branch=main https://github.com/pymor/pymor-deal.II deal && \
    cd deal && python setup.py bdist_wheel && \
    mkdir /usr/local/tmp/ && \
    mv dist/*.whl /usr/local/tmp/ && \
    printenv > /usr/local/share/dealii.env

# THE END
ENV DEBIAN_FRONTEND teletype
