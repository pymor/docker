FROM docker.io/library/docker:19.03.13-dind@sha256:7efc658176afab9a80c450510882e3176c351ec0fad557b6dd98636b5af474c7
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOCKER_BUILDKIT=1 \
    DOCKER_CLI_EXPERIMENTAL=enabled \
    DX_VERSION=v0.4.2
RUN apk --update add openssh-client rsync git file bash python3 py3-pip curl make \
  && pip3 install --no-cache ruamel.yaml==0.15.100 jinja2 jupyter-repo2docker docker-compose \
  && mkdir -p /root/.docker/cli-plugins \
  && wget -O /root/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/$DX_VERSION/buildx-$DX_VERSION.linux-amd64 \
  && chmod a+x /root/.docker/cli-plugins/docker-buildx
