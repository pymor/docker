#!/usr/bin/env bash

BRANCH=$1
shift

set -eux

git clone --branch=${BRANCH} https://github.com/pymor/pymor /tmp/pymor
cd /tmp/pymor
python setup.py build_ext -i
make -C docs html
mkdir /home/pymor/docs
mv docs/_build/html /home/pymor/docs/${BRANCH}
rm -rf /tmp/pymor
