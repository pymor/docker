FROM REGISTRY/pymor/python_PYVER:VERTAG as foam_builder

ENV OPENFOAM_DIR=/usr/local/src/openfoam

SHELL ["/bin/bash", "-c"]

RUN MOUNT_CACHE \
  echo 'APT::Default-Release "buster";' > /etc/apt/apt.conf.d/default-release \
  && echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list \
  && echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list \
  && apt update \
  && ${APTINSTALL} -t buster-backports libboost1.71-all-dev \
  && ${APTINSTALL} gnupg ca-certificates git debhelper build-essential \
                  flex libfl-dev gfortran \
                  libreadline-dev libscotch-dev libptscotch-dev libfftw3-dev \
  && git clone --branch=OpenFOAM-v2106 https://develop.openfoam.com/Development/openfoam.git ${OPENFOAM_DIR} \
  && cd ${OPENFOAM_DIR} \
  && source etc/bashrc \
  && ./Allwmake -j -s -q -l 
