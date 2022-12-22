# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder_PYVER_VERTAG

# the env var disappears between end of this run and start of next...
RUN MOUNT_CACHE \
  PIP_SELF_UPDATE \
  && PIP_CHECK \
  && ${PIP_INSTALL} pypi-oldest-requirements>=2022.1.0 cython

# cache busting opportunity
COPY bumpfile /tmp
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /wheelhouse/ci_wheels.list /ci_wheels/
COPY requirements* /requirements/

COPY constraints.bash /usr/local/bin
RUN MOUNT_CACHE \
  PIP_SELF_UPDATE \
  && PIP_CHECK \
  && constraints.bash ${PYTHON_PIP_VERSION}

RUN echo "${PYTHON_PIP_VERSION}" > /requirements/pip_version
FROM ALPINE_VERSION

# for compat with general run_* makefile target
RUN apk add bash py3-pip

COPY --from=builder_PYVER_VERTAG /requirements/* /requirements/
COPY transform_wheel_uris.py /usr/local/bin/
RUN python3 -m pip install wheel-filename==1.3.0 check_reqs pip==$(cat /requirements/pip_version)\
  && cd /requirements \
  && python3 /usr/local/bin/transform_wheel_uris.py constraints.txt \
  && python3 /usr/local/bin/transform_wheel_uris.py oldest_constraints.txt
