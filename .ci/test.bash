#!/usr/bin/env bash

set -exu

git clone https://github.com/pymor/pymor /tmp/src
cd /tmp/src
${PIP_INSTALL} .[full,docs,ci]
python -c "from pymor.basic import *"
python -c "from qtpy.QtWidgets import *"
python -c "from dolfin import *"
python -c "from ngsolve import *"
