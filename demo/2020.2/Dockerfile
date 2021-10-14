FROM docker.io/pymor/testing_py3.8:2020.2.0
MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
RUN apt-get update && \
    apt-get install --no-install-recommends -y xvfb libgl1-mesa-dri libglu1-mesa libglvnd0 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --shell /bin/bash -u 1000 -o -c "" -m pymor \
    && ${PIP_INSTALL} "pymor>=2020.1,<2020.2"
USER pymor

RUN pymor-demo --help && python -c "from pymor.basic import *"

ENV LIBGL_DEBUG=verbose
ENTRYPOINT ["/usr/local/bin/pymor-demo"]
CMD ["--help"]
