FROM docker.io/pymor/jupyter_py3.9:2022.1.0
MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
RUN useradd --shell /bin/bash -u 1000 -o -c "" -m pymor \
    && ${PIP_INSTALL} "pymor>=2022.1.0,<2022.2"
USER pymor

RUN pymor-demo --help && python -c "from pymor.basic import *"

ENV LIBGL_DEBUG=verbose
ENTRYPOINT []
