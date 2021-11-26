# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder_PYVER_VERTAG

ENV MIRROR_VERSION=4.0.5 \
  SERVER_ROOT=/pymor \
  PYTHON_VERSION=PYVER \
  XDG_CACHE_HOME=/cache \
  DOWNLOAD="/tmp/venv/bin/pip download --no-deps -d /pymor/downloads" \
  PIP="/tmp/venv/bin/pip"

RUN MOUNT_CACHE \
  ${PIP_INSTALL} "python-pypi-mirror==${MIRROR_VERSION}"  \
    pypi-oldest-requirements>=2020.4.1 requests-toolbelt virtualenv \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT} \
  && virtualenv /tmp/venv

COPY --from=zivgitlab.wwu.io/pymor/docker/pymor/constraints_pyPYVER:VERTAG /requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whole process
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /tmp/
RUN MOUNT_CACHE \
  ${DOWNLOAD} /tmp/*whl && rm -f /tmp/*whl \
  && set -uex \
  && grep -v "file\:" ${SERVER_ROOT}/requirements/oldest_constraints.txt > ${SERVER_ROOT}/requirements/no_files_oldest_constraints.txt \
  && ${DOWNLOAD} -r  ${SERVER_ROOT}/requirements/no_files_oldest_constraints.txt \
  && cd ${SERVER_ROOT}/ \
  && pypi-mirror create -d downloads -m simple \
  && rm -rf /tmp/*

FROM alpine:3.12

ENV SERVER_ROOT=/pymor

COPY --from=builder_PYVER_VERTAG ${SERVER_ROOT}/ ${SERVER_ROOT}
RUN apk add -U python3 bash \
  && adduser -D -s /bin/bash -u 1000 -h /data pymor \
  && chown pymor ${SERVER_ROOT}

USER pymor
WORKDIR ${SERVER_ROOT}
EXPOSE 8080
ENTRYPOINT ["python3", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
