FROM debian:buster-20201117-slim

RUN apt update -y && apt install -y python3-pip && \
    apt remove -y gcc && apt autoremove -y && \
    pip3 install pip==19.0

COPY pip.conf /etc/
