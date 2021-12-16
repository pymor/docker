#!/usr/bin/env bash

set -exu

rm -rf /src
mkdir /src
pip install -U wheel pymor-oldest-supported-numpy~=2021.1.0
declare -A VERSIONS=( ["slycot"]="~=0.4.0" ["mpi4py"]=">=3" ["gmsh"]="~=4.8.0" ["petsc4py"]="==${PETSC4PY_VERSION}" ["mpi4py"]=">=3")

for pkg in ${WHEEL_PKGS} ; do
  cd /src
  ver="${VERSIONS[${pkg}]}"
  pip download --no-deps ${pkg}${ver} -d /src/
  unp /src/${pkg}*.tar.gz && rm /src/${pkg}*.tar.gz
  cd ${pkg}*
  pip wheel --use-feature=in-tree-build . -w ${WHEELHOUSE}/tmp
  mv ${WHEELHOUSE}/tmp/${pkg}* ${WHEELHOUSE}/
  rm -rf ${WHEELHOUSE}/tmp
done

pip download --no-deps torch==1.8.1+cpu torchvision==0.9.1+cpu torchaudio==0.8.1 \
  -f https://download.pytorch.org/whl/torch_stable.html -d ${WHEELHOUSE}/
