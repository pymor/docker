FROM python:3.9-slim-buster

ENV DEVPI_SERVER_VERSION=6.2.0 \
  DEVPI_CLIENT_VERSION=5.2.2
COPY entrypoint.bash /bin/entrypoint.bash

RUN chmod +x /bin/entrypoint.bash \
  && pip install devpi-server==${DEVPI_SERVER_VERSION} devpi-client==${DEVPI_CLIENT_VERSION}  \
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m  pymor

ENTRYPOINT ["/bin/entrypoint.bash"]
