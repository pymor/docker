# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder_PYVER_VERTAG

RUN MOUNT_CACHE \
  pip install pypi-oldest-requirements>=2020.4.2 cython

# cache busting opportunity
COPY bumpfile /tmp
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /wheelhouse/ci_wheels.list /ci_wheels/
COPY requirements* /requirements/

COPY check_reqs.py constraints.bash /usr/local/bin
RUN constraints.bash

FROM alpine:3.12

# for compat with general run_* makefile target
RUN apk add bash py3-pip

COPY --from=builder_PYVER_VERTAG /requirements/* /requirements/
COPY --from=builder_PYVER_VERTAG /usr/local/bin/check_reqs.py /usr/local/bin/
COPY transform_wheel_uris.py /usr/local/bin/
RUN python3 -m pip install wheel-filename==1.3.0 \
  && cd /requirements \
  && python3 /usr/local/bin/transform_wheel_uris.py constraints.txt \
  && python3 /usr/local/bin/transform_wheel_uris.py oldest_constraints.txt
