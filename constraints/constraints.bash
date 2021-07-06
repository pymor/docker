#!/usr/bin/env bash
set -exo pipefail
# fenics and pymor-deallii packages need to be filtered from the freeze command since they're already installed
# in the constaints base image and cannot be installed from pypi

REQUIREMENTS="requirements.txt requirements-ci.txt requirements-optional.txt requirements-docker-other.txt"

# these are copied from the pymor/ci_wheels image
pip install /ci_wheels/*whl

cd /requirements/
for fn in ${REQUIREMENTS} ; do
    PARG="-r ${fn} ${PARG}"
done
pip install ${PARG}

for fn in ${REQUIREMENTS} ; do
    check_reqs.py ${fn}
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

virtualenv /tmp/venv_old

/tmp/venv_old/bin/pip install /ci_wheels/*whl
/tmp/venv_old/bin/pip install -r combined_oldest.txt
/tmp/venv_old/bin/python /usr/local/bin/check_reqs.py combined_oldest.txt

# torch is still excluded here since it cannot be installed from pypi
/tmp/venv_old/bin/pip freeze --all | grep -v fenics | grep -v torch | grep -v dolfin |grep -v dealii \
  > /requirements/oldest_constraints.txt
