FROM python:3.9-slim-bullseye

ENV DEVPI_SERVER_VERSION=6.8.0 \
  DEVPI_CLIENT_VERSION=6.0.2

RUN \
  PIP_SELF_UPDATE \
  && PIP_CHECK \
  && pip install https://m.devpi.net/fschulze/dev/+f/6ac/e7aaa2d1196f1/devpi_common-3.7.1.dev0-py2.py3-none-any.whl \
  && pip install devpi-server==${DEVPI_SERVER_VERSION} devpi-client==${DEVPI_CLIENT_VERSION}  \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m  pymor

COPY entrypoint.bash /bin/entrypoint.bash
RUN chmod +x /bin/entrypoint.bash
ENTRYPOINT ["/bin/entrypoint.bash"]
