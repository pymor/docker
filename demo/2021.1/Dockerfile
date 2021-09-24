FROM docker.io/pymor/testing_py3.8:2020.2.0
MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
RUN useradd --shell /bin/bash -u 1000 -o -c "" -m pymor \
    && ${PIP_INSTALL} "pymor~=2021.1"
USER pymor

RUN pymor-demo --help && python -c "from pymor.basic import *"

ENV LIBGL_DEBUG=verbose
ENTRYPOINT ["/usr/local/bin/pymor-demo"]
CMD ["--help"]
