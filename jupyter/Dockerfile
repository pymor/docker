# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/testing_pyPYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

# the pythreejs needs npm/nodejs installed for the jupter lab extension
RUN MOUNT_CACHE \
    /bin/bash -c "curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    &&  apt update && ${APTINSTALL} nodejs &&\
    PIP_SELF_UPDATE && \
    PIP_CHECK && \
    ${PIP_INSTALL} jupyterlab && \
    ${PIP_INSTALL} pythreejs && \
    ${PIP_INSTALL} nbresuse jupyter_contrib_nbextensions && \
    find /usr -name .cache | xargs rm -rf"
COPY dev-entrypoint.bash /usr/local/bin/
COPY ipython_kernel_config.py /etc/ipython/

RUN chmod +rx /usr/local/bin/*
ENTRYPOINT ["/usr/local/bin/dev-entrypoint.bash"]
