#!/usr/bin/env bash

set -exu

rm -rf /src
mkdir /src
pip install -U wheel pymor-oldest-supported-numpy~=2021.1.0 scikit-build
declare -A VERSIONS=( ["slycot"]="~=0.5.0" ["mpi4py"]=">=3" ["petsc4py"]="==${PETSC4PY_VERSION}" ["mpi4py"]=">=3")

for pkg in ${WHEEL_PKGS} ; do
  cd /src
  ver="${VERSIONS[${pkg}]}"
  pip download --no-deps ${pkg}${ver} -d /src/
  unp /src/${pkg}*.tar.gz && rm /src/${pkg}*.tar.gz
  cd ${pkg}*
  pip wheel . -w ${WHEELHOUSE}/tmp
  pip install ${WHEELHOUSE}/tmp/*.whl
  mv ${WHEELHOUSE}/tmp/*.whl ${WHEELHOUSE}/
  rm -rf ${WHEELHOUSE}/tmp
done

pip download --no-deps torch==1.11.0+cpu torchvision==0.12.0+cpu torchaudio==0.11.0 \
  -f https://download.pytorch.org/whl/torch_stable.html -d ${WHEELHOUSE}/
