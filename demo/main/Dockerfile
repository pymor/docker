FROM pymor/testing_py3.9:eb048594eee4e97b1b714503a06e7a5bfe3cabf6
MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
RUN apt-get update && apt-get install \
        --no-install-recommends -y xauth x11-apps xvfb libgl1-mesa-dri libglu1-mesa \
        libgsl-dev \
        liblapack-dev \
        libnetcdf-c++4-dev \
        libnetcdf-cxx-legacy-dev \
        libnetcdf-dev \
        libarpack2-dev libgmsh-dev \
        liblapack-dev libmuparser-dev libmetis-dev libtbb-dev \
    && pip uninstall -y pymor numpy \
    && ${PIP_INSTALL} -U pip~=21.1 \
    && ${PIP_INSTALL} git+https://github.com/pymor/pymor.git@main#egg=pymor[full] \
    && rm -rf ~/.matplotlib \
    && apt-get autoremove -y  \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --shell /bin/bash -u 1000 -o -c "" -m pymor

USER pymor

RUN pymor-demo --help && python -c "from pymor.basic import *"

ENV LIBGL_DEBUG=verbose
# ENTRYPOINT ["/usr/local/bin/pymor-demo"]
# CMD ["--help"]
