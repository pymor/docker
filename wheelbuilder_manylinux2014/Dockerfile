# EXPERIMENTAL_SYNTAX
FROM quay.io/pypa/manylinux2014_x86_64:2021-06-07-00faba2

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV MPICC=/usr/lib64/openmpi/bin/mpicc \
    PYTHON_VERSION=PYVER \
    PIP_VERSION=21.2.4 \
    WHEEL_DIR=/io/wheelhouse \
    XDG_CACHE_HOME=/cache \
    PLATFORM=manylinux2014_x86_64

RUN MOUNT_CACHE \
  yum install -y atlas-devel openmpi-devel  \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth openblas-devel

COPY --from=REGISTRY/pymor/pypi-mirror_oldest_pyPYVER:VERTAG /pymor/downloads/* ${WHEEL_DIR}/
COPY pybin.sh /etc/profile.d/

# installing scipy after numpy prevents scipy from trying to compile numpy from source
# some packages get installed manually because others have broken dependency settings
# --only-binary for packages that got additional source tarball downloads that shouldn't be installed
RUN MOUNT_CACHE \
  source /etc/profile.d/pybin.sh && \
  ${PYBIN}/pip install --no-cache -U pip==${PIP_VERSION} && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/numpy* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/scipy* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/*manylinux2014_x86_64.whl && \
  rm -f ${WHEEL_DIR}/*manylinux2014_x86_64.whl && \
  ${PYBIN}/pip install --only-binary mpi4py --no-cache ${WHEEL_DIR}/*

COPY entrypoint.sh /usr/local/bin/
COPY build-wheels.sh /usr/local/bin/
COPY gosu-amd64 /usr/local/bin/gosu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/build-wheels.sh"]
