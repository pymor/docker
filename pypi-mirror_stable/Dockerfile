# EXPERIMENTAL_SYNTAX
FROM python:PYVER

ENV MIRROR_VERSION=4.0.5 \
  PIP_VERSION=21.2.4 \
  SERVER_ROOT=/pymor \
  XDG_CACHE_HOME=/cache \
  DOWNLOAD="pip download --no-deps -d /pymor/downloads"

RUN MOUNT_CACHE \
  pip install -qq "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
    pypi-oldest-requirements>=2020.4.1 requests-toolbelt \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}

COPY --from=zivgitlab.wwu.io/pymor/docker/pymor/constraints_pyPYVER:VERTAG /requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable package cannot be downloaded and would error out the whole process
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /tmp/
COPY extra_version_downloads.txt /tmp/
RUN MOUNT_CACHE \
  ${DOWNLOAD} /tmp/*whl && rm /tmp/*whl \
  && set -uex \
  && ${DOWNLOAD} -r ${SERVER_ROOT}/requirements/constraints.txt \
  && ${DOWNLOAD} -r /tmp/extra_version_downloads.txt \
  && cd ${SERVER_ROOT}/ \
  && pypi-mirror --print-traceback create  -d downloads -m simple \
  && rm -rf /tmp/*


USER pymor
WORKDIR ${SERVER_ROOT}
EXPOSE 8080
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
