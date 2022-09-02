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
    ${PIP_INSTALL} jupytext && \
    ${PIP_INSTALL} nbresuse jupyter_contrib_nbextensions && \
    find /usr -name .cache | xargs rm -rf"
COPY start_jupyter.bash /usr/local/bin/
COPY ipython_kernel_config.py /etc/ipython/
COPY start.md /notebooks/
RUN chmod +rx /usr/local/bin/* && \
  cd /notebooks && \
  jupytext start.md --to ipynb
EXPOSE 8888
CMD ["/usr/local/bin/start_jupyter.bash"]
