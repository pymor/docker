# EXPERIMENTAL_SYNTAX
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive \
    APTINSTALL="apt-get install -qq -y --no-install-recommends" \
    PIP_INSTALL="python3 -m pip install --no-cache-dir " \
	PYTHON_PIP_VERSION=22.3.1 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    CCACHE_DIR=/cache/ccache \
    XDG_CACHE_HOME=/cache \
    PATH=/usr/lib/ccache:${PATH} \
    PYBIND11_VERSION=2.8.1 \
    PYMOR_OLDEST_NUMPY_VERSION==2023.1.4

# python's configured to use system's expat and ffi libs
RUN MOUNT_CACHE \
  echo "C.UTF-8 UTF-8" > /etc/locale.gen && \
	apt update -qq \
	&& ${APTINSTALL} libexpat1 libffi7 \
	libbz2-1.0 \
	libc6 \
	libcurl4 \
	libdb5.3 \
	libevent-2.1-7 \
	libgdbm6 \
	libglib2.0 \
	libjpeg62-turbo \
	liblzma5 \
	libncurses5 \
	libncursesw5 \
	libpng16-16 \
	libreadline8  \
	libsqlite3-0  \
	libssl1.1 \
	libfreetype6 \
	tcl \
	tk \
  ccache \
	&& rm -rf /tmp/* /var/tmp/*

COPY --from=REGISTRY/pymor/python_builder_PYVER:VERTAG /usr/local/ /usr/local/
RUN ldconfig \
  && PIP_SELF_UPDATE \
  && PIP_CHECK \
  && printenv > /usr/local/share/python.env

CMD ["python3"]
