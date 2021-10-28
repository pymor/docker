#!/usr/bin/env bash

set -eux

wget -O /tmp/cmake.sh https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-x86_64.sh
bash /tmp/cmake.sh --skip-license --prefix=/usr/local
cmake --version

pip install numba /tmp/mpi4py* pybind11
pip install --no-deps petsc4py==${PETSC4PY_VERSION}
python -c "import petsc4py"
mkdir /src
cd /src
for i in basix fiat ufl ffcx dolfinx ; do
  git clone https://github.com/FEniCS/$i /src/$i
done

cd /src/dolfinx
git remote add fork  https://github.com/renefritze/dolfinx
git fetch fork
git checkout fork/fix_interpreter_passing

mkdir /src/basix/build
cd /src/basix/build
cmake -B /src/basix/build -DCMAKE_BUILD_TYPE=Release -S /src/basix/ -DPYTHON_INTERPRETER=/usr/local/bin/python3
cmake --build /src/basix/build
cmake --install /src/basix/build

pip install /src/basix/python

# (for i in basix fiat ufl ffcx dolfinx; do cd /src/$i && git checkout ${DOLFINX_VERSION} || exit 1 ; done) && \
for i in fiat ufl ffcx ; do
  cd /src/$i
  pip install --no-cache-dir .
done

apt update
apt install -y ninja-build
cd /src/dolfinx
mkdir build
cd build
PETSC_ARCH=linux-gnu-real-32 cmake -G Ninja \
  -DCMAKE_INSTALL_PREFIX=/usr/local/ \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_INTERPRETER=/usr/local/bin/python3 \
  ../cpp
ninja install
cd ../python
PETSC_ARCH=linux-gnu-real-32 pip3 install .
(find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null )
ldconfig
rm -rf /src
printenv >> /usr/local/share/dolfinx.env
