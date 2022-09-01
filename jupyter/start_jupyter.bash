#!/bin/bash

set -exuo pipefail

cd /notebooks
pip install pymor[full]
jupytext start.md --to ipynb
jupyter notebook start.ipynb --allow-root --ip=0.0.0.0 --no-browser --notebook-dir=/notebooks
