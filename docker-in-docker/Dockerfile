FROM docker.io/library/docker:20.10.17-dind@sha256:8cdb600dd59001892484f7c4be06166e42a2952065b6822b98c5aa7b8ef2ce8b
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOCKER_BUILDKIT=1 \
    DOCKER_CLI_EXPERIMENTAL=enabled \
    DX_VERSION=v0.8.2
RUN apk --update add docker-cli-compose docker-cli-buildx openssh-client rsync git file bash python3 py3-pip curl make \
  && pip3 install jinja2
