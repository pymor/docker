# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOCKER_NGSOLVE=1 \
    DOCKER_PYMOR=1 \
    OPENBLAS_NUM_THREADS=1 \
    GOTO_NUM_THREADS=1 \
    OMP_NUM_THREADS=1 \
    DEBIAN_FRONTEND=teletype

# -dev packages should be kept as few as possible, and listed here with reasoning
# matplotlib/Qt backend: libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
#     libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 libxcb-util0
# gmsh: libxcursor1 libxinerama1
RUN MOUNT_CACHE \
    echo 'APT::Default-Release "bullseye";' > /etc/apt/apt.conf.d/default-release && \
    echo "#deb http://deb.debian.org/debian bullseye-backports main contrib non-free" > /etc/apt/sources.list.d/bullseye-backports.list && \
    echo "#deb http://deb.debian.org/debian/ bullseye contrib non-free" > /etc/apt/sources.list.d/bullseye-nonfree.list && \
    apt update && \
    ${APTINSTALL} wget curl less \
        xvfb gnupg ca-certificates \
        gcc g++ gfortran make dirmngr pandoc \
        swig cmake libopenblas-dev \
        ninja-build \
        xauth gsl-bin git-lfs \
        vim gosu sudo \
        libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
          libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 libxcb-util1\
        libxcursor1 libxinerama1 && \
    echo "alias ls='ls -h --color=auto'" >> /etc/bash.bashrc && \
    echo "alias ll='ls -lh'" >> /etc/bash.bashrc && \
    echo "source /usr/local/share/dolfin/dolfin.conf" >> /etc/bash.bashrc && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN MOUNT_CACHE \
    ${PIP_INSTALL} termtables python-dotenv # for pymor-info script

COPY pymor-info /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
COPY *.pip.conf /usr/local/share/
COPY packages.list.txt /tmp
COPY --from=pymor/pypi-mirror_stable_pyPYVER:VERTAG /pymor/downloads/* /tmp/dependencies/
RUN MOUNT_CACHE \
    set -exu \
    && PIP_SELF_UPDATE \
    && PIP_CHECK \
    && ${PIP_INSTALL} -f /tmp/dependencies/ -r /tmp/packages.list.txt \
    && rm -rf /tmp/*


# from here on images are user facing, unset away from mounted cache
ENV CCACHE_DIR=/tmp/ccache \
    XDG_CACHE_HOME=
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["./.ci/gitlab/script.bash"]
