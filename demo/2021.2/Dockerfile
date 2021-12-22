FROM docker.io/pymor/jupyter_py3.9:2021.2.0
MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
RUN useradd --shell /bin/bash -u 1000 -o -c "" -m pymor \
    && ${PIP_INSTALL} "pymor~=2021.2.0"
USER pymor

RUN pymor-demo --help && python -c "from pymor.basic import *"

ENV LIBGL_DEBUG=verbose
ENTRYPOINT []
