PYTHONS = 3.6 3.7 3.8 3.9
VER?=$(shell git log -1 --pretty=format:"%H")
NGSOLVE_IMAGE = pymor/ngsolve_py$1:$2
PETSC_IMAGE = pymor/petsc_py$1:$2
PYTHON_IMAGE = pymor/python_$1:$2
FENICS_IMAGE = pymor/fenics_py$1:$2
DEALII_IMAGE = pymor/dealii_py$1:$2
CIBASE_IMAGE = pymor/cibase_py$1:$2
DIND_IMAGE = pymor/docker-in-docker:$2
TESTING_IMAGE = pymor/testing_py$1:$2
PYPI_MIRROR_OLDEST_IMAGE = pymor/pypi-mirror_oldest_py$1:$2
PYPI_MIRROR_STABLE_IMAGE = pymor/pypi-mirror_stable_py$1:$2
CONSTRAINTS_IMAGE = pymor/constraints_py$1:$2
DOC_RELEASES_IMAGE = pymor/doc_releases:$2
JUPYTER_IMAGE = pymor/jupyter_py$1:$2
MIRROR_TEST_IMAGE = pymor/pypi-mirror_test_py$1:$2
WHEELBUILDER_IMAGE = wrong_image_name
WB1_IMAGE = pymor/wheelbuilder_manylinux1_py$1:$2
WB2010_IMAGE = pymor/wheelbuilder_manylinux2010_py$1:$2
WB2014_IMAGE = pymor/wheelbuilder_manylinux2014_py$1:$2
# CNTR_BUILD=$(CNTR_CMD) build --squash
CNTR_CMD?=docker
CNTR_BUILD=$(CNTR_CMD) build
COMMON_BUILD=$(CNTR_BUILD) -t $(call $(IMAGE_NAME),$*,$(VER)) --build-arg PYVER=$* --build-arg VERTAG=$(VER) \
	--cache-from=$(call $(IMAGE_NAME),$*,$(VER)) --cache-from=$(call $(IMAGE_NAME),$*,latest)
CNTR_TAG=$(CNTR_CMD) tag
CNTR_PUSH=$(CNTR_CMD) push
CNTR_PULL=$(CNTR_CMD) pull -q
CNTR_RUN=$(CNTR_CMD) run
CNTR_RMI=$(CNTR_CMD) rmi -f
CNTR_INSPECT=$(CNTR_CMD) inspect
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)
PYMOR_BRANCH=master
MANYLINUXS=1 2010 2014
DISTROS = centos_8 debian_stretch debian_buster debian_bullseye
DEMO_TAGS = 0.5 master 2019.2
