#!/bin/bash

USER_ID=${LOCAL_USER_ID:-1000}

echo "Starting with UID : $USER_ID"

# we are running as root (if USER_ID == 0) there is little we can do but continue ...
if [[ $UID_ == 0 ]] ; then
  mkdir -p /home/pymor
  export HOME=/home/pymor
  if [ "X$@" == "X" ]; then
    exec /bin/bash
  else
    exec "$@"
  fi
  exit
fi

# else create user pymor with correct id
useradd --shell /bin/bash -u $USER_ID -o -c "" -m pymor && \
    adduser pymor sudo &&\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
export HOME=/home/pymor

exec gosu pymor "$@"
