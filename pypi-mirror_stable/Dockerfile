# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder_PYVER_VERTAG

ENV MIRROR_VERSION=4.0.5 \
  SERVER_ROOT=/pymor \
  XDG_CACHE_HOME=/cache \
  DOWNLOAD="pip download --no-deps -d /pymor/downloads"

RUN MOUNT_CACHE \
  ${PIP_INSTALL} install "python-pypi-mirror==${MIRROR_VERSION}" \
    pypi-oldest-requirements>=2020.4.1 requests-toolbelt

COPY --from=zivgitlab.wwu.io/pymor/docker/pymor/constraints_pyPYVER:VERTAG /requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whole process
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /tmp/
COPY extra_version_downloads.txt /tmp/
RUN MOUNT_CACHE \
  set +x ; \
  ${DOWNLOAD} /tmp/*whl && rm -f /tmp/*whl \
  && set -uex \
  && grep -v "file\:" ${SERVER_ROOT}/requirements/constraints.txt > ${SERVER_ROOT}/requirements/no_files_constraints.txt \
  && ${DOWNLOAD} --platform=manylinux2014_x86_64 -r ${SERVER_ROOT}/requirements/no_files_constraints.txt \
  && ${DOWNLOAD} --platform=manylinux2014_x86_64 -r /tmp/extra_version_downloads.txt \
  && cd ${SERVER_ROOT}/ \
  && pypi-mirror --print-traceback create  -d downloads -m simple \
  && rm -rf /tmp/*

FROM alpine:3.12

ENV SERVER_ROOT=/pymor

RUN apk add -U python3 bash \
  && adduser -D -s /bin/bash -u 1000 -h /data pymor

COPY --chown=pymor --from=builder_PYVER_VERTAG ${SERVER_ROOT}/ ${SERVER_ROOT}

USER pymor
WORKDIR ${SERVER_ROOT}
EXPOSE 8080
ENTRYPOINT ["python3", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
