FROM REGISTRY/pymor/python_PYVER:VERTAG as foam_builder

ENV OPENFOAM_DIR=/usr/local/src/openfoam

RUN MOUNT_CACHE \
  apt update \
  && ${APTINSTALL} libboost1.74-all-dev \
  && ${APTINSTALL} gnupg ca-certificates git debhelper build-essential \
                  flex libfl-dev gfortran \
                  libreadline-dev libscotch-dev libptscotch-dev libfftw3-dev \
  && git clone --branch=OpenFOAM-v2106 https://develop.openfoam.com/Development/openfoam.git ${OPENFOAM_DIR} 

SHELL ["/bin/bash", "-c"]

RUN MOUNT_CACHE \
  cd ${OPENFOAM_DIR} \
  && source etc/bashrc \
  && ./Allwmake -j -s -q -l 
