#!/usr/bin/env bash
set -uexo pipefail
# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constaints base image and cannot be installed from pypi

PYTHON_PIP_VERSION="${1}"
shift

REQUIREMENTS="requirements.txt requirements-ci.txt requirements-optional.txt requirements-docker-other.txt"

python -m pip install pip==${PYTHON_PIP_VERSION}

# these are copied from the pymor/ci_wheels image
${PIP_INSTALL} /ci_wheels/*whl
${PIP_INSTALL} check_reqs

cd /requirements/
PARG=
for fn in ${REQUIREMENTS} ; do
    PARG="-r ${fn} ${PARG}"
done
${PIP_INSTALL} ${PARG}

for fn in ${REQUIREMENTS} ; do
    check_reqs ${fn}
done

pip freeze --all | grep -v fenics | grep -v dolfin |grep -v dealii \
  > /requirements/constraints.txt

cd /requirements/
pypi_minimal_requirements_pinned ${REQUIREMENTS} --output-fn combined_oldest.txt
# manully installed wheels need to be filtered, otherwise
# versions not matching the wheels' will conflict on requirements install
for pkg in $(cat /ci_wheels/ci_wheels.list) ; do
  sed -i "/${pkg}/d" combined_oldest.txt
done

python -m virtualenv --pip "${PYTHON_PIP_VERSION}" /tmp/venv_old

/tmp/venv_old/bin/${PIP_INSTALL} /ci_wheels/*whl
/tmp/venv_old/bin/${PIP_INSTALL} check_reqs
/tmp/venv_old/bin/${PIP_INSTALL} -r combined_oldest.txt
/tmp/venv_old/bin/python -m check_reqs combined_oldest.txt

# torch is still excluded here since it cannot be installed from pypi
/tmp/venv_old/bin/pip freeze --all | grep -v fenics | grep -v torch | grep -v dolfin |grep -v dealii \
  > /requirements/oldest_constraints.txt
