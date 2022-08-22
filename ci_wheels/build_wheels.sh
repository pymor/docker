#!/usr/bin/env bash

set -exu

rm -rf /src
mkdir /src
pip install -U wheel pymor-oldest-supported-numpy~=2021.1.0 scikit-build
declare -A VERSIONS=( ["slycot"]="~=0.5.0" ["mpi4py"]=">=3" ["gmsh"]="~=4.8.0" ["petsc4py"]="==${PETSC4PY_VERSION}" ["mpi4py"]=">=3" ["cppyy-backend"]="==1.14.9" ["cppyy"]="==2.4.0")

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
  cd -
  rm -rf ${pkg}*
done

pip download --no-deps torch==1.8.1+cpu torchvision==0.9.1+cpu torchaudio==0.8.1 \
  -f https://download.pytorch.org/whl/torch_stable.html -d ${WHEELHOUSE}/
