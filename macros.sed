s;MOUNT_CACHE;--mount=type=cache,sharing=locked,id=pymor_aptcache_PYVER,target=/var/cache/apt --mount=type=cache,sharing=locked,id=pymor_cache_PYVER,target=/cache/ --mount=type=cache,sharing=locked,id=pymor_aptlib_PYVER,target=/var/lib/apt ;g
s;EXPERIMENTAL_SYNTAX;syntax = docker/dockerfile:experimental;g
s;MAKE_ARGS;-j $(nproc --ignore=1) -l $(nproc --ignore=2);g
s;PIP_CHECK;test "\$\{PYTHON_PIP_VERSION\}" = "\$\(python3 -c 'import pip\;print(pip.__version__)'\)";g
s;PIP_SELF_UPDATE;python3 -m pip install pip==${PYTHON_PIP_VERSION};g
