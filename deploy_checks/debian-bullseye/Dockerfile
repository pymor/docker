FROM debian:bullseye-20211011-slim

RUN apt update -y && apt install -y python3-pip python3-wheel && \
    apt remove -y gcc && apt autoremove -y

COPY pip.conf /etc/
