#!/bin/bash

set -exuo pipefail

cd /notebooks
pip install pymor[full]
jupyter notebook start.ipynb --allow-root --ip=0.0.0.0 --no-browser --notebook-dir=/notebooks
