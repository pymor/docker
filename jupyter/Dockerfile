# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/testing_pyPYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

# the pythreejs needs npm/nodejs installed for the jupter lab extension
RUN MOUNT_CACHE \
    /bin/bash -c "curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    &&  apt update && ${APTINSTALL} nodejs &&\
    ${PIP_INSTALL} jupyterlab pythreejs && \
    jupyter nbextension install --py --symlink --sys-prefix pythreejs && \
    jupyter nbextension install --py --symlink --sys-prefix ngsolve && \
    jupyter nbextension enable --py --sys-prefix pythreejs && \
    jupyter nbextension enable --py --sys-prefix ngsolve && \
    jupyter labextension install jupyter-threejs && \
    ${PIP_INSTALL} nbresuse jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable notify/notify && \
    jupyter nbextension enable scroll_down/main && \
    find /usr -name .cache | xargs rm -rf"
COPY dev-entrypoint.bash /usr/local/bin/
COPY ipython_kernel_config.py /etc/ipython/

RUN chmod +rx /usr/local/bin/*
ENTRYPOINT ["/usr/local/bin/dev-entrypoint.bash"]
