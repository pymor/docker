PYTHONS = 3.6 3.7 3.8 3.9
VER?=$(shell git log -1 --pretty=format:"%H")
NGSOLVE_IMAGE = pymor/ngsolve_py$1:$2
NGSOLVE_IMAGE_DIR = ngsolve/docker
PETSC_IMAGE = pymor/petsc_py$1:$2
PETSC_IMAGE_DIR = petsc/docker
PYTHON_IMAGE = pymor/python_$1:$2
PYTHON_IMAGE_DIR = python
PYTHON_BUILDER_IMAGE = pymor/python_builder_$1:$2
PYTHON_BUILDER_IMAGE_DIR = python_builder/$1/buster/slim
FENICS_IMAGE = pymor/fenics_py$1:$2
FENICS_IMAGE_DIR = fenics/docker
DEALII_IMAGE = pymor/dealii_py$1:$2
DEALII_IMAGE_DIR = dealii/docker
CIBASE_IMAGE = pymor/cibase_py$1:$2
CIBASE_IMAGE_DIR = cibase/buster
DIND_IMAGE = pymor/docker-in-docker:$2
DIND_IMAGE_DIR = docker-in-docker
TESTING_IMAGE = pymor/testing_py$1:$2
TESTING_IMAGE_DIR = testing/$1
PYPI_MIRROR_OLDEST_IMAGE = pymor/pypi-mirror_oldest_py$1:$2
PYPI_MIRROR_OLDEST_IMAGE_DIR = pypi-mirror_oldest
PYPI_MIRROR_STABLE_IMAGE = pymor/pypi-mirror_stable_py$1:$2
PYPI_MIRROR_STABLE_IMAGE_DIR = pypi-mirror_stable
CONSTRAINTS_IMAGE = pymor/constraints_py$1:$2
CONSTRAINTS_IMAGE_DIR = constraints
DOC_RELEASES_IMAGE = pymor/doc_releases:$2
DOC_RELEASES_IMAGE_DIR = docs
JUPYTER_IMAGE = pymor/jupyter_py$1:$2
JUPYTER_IMAGE_DIR = jupyter
MIRROR_TEST_IMAGE = pymor/pypi-mirror_test_py$1:$2
MIRROR_TEST_IMAGE_DIR = pypi-mirror_test
WHEELBUILDER_IMAGE = wrong_image_name
WB1_IMAGE = pymor/wheelbuilder_manylinux1_py$1:$2
WB1_IMAGE_DIR = wheelbuilder_manylinux1
WB2010_IMAGE = pymor/wheelbuilder_manylinux2010_py$1:$2
WB2010_IMAGE_DIR = wheelbuilder_manylinux2010
WB2014_IMAGE = pymor/wheelbuilder_manylinux2014_py$1:$2
WB2014_IMAGE_DIR = wheelbuilder_manylinux2014
# CNTR_BUILD=$(CNTR_CMD) build --squash
CNTR_CMD?=docker
CNTR_BUILD=$(CNTR_CMD) buildx build
CNTR_TAG=$(CNTR_CMD) tag
CNTR_PUSH=$(CNTR_CMD) push
CNTR_PULL=$(CNTR_CMD) pull -q
CNTR_RUN=$(CNTR_CMD) run
CNTR_RMI=$(CNTR_CMD) rmi -f
CNTR_INSPECT=$(CNTR_CMD) inspect
COMMON_INSPECT=$(CNTR_INSPECT) $(call $(IMAGE_NAME),$*,$(VER)) >/dev/null 2>&1
CACHE_FROM=$$( ($(CNTR_INSPECT) $(call $(IMAGE_NAME),$*,latest) >/dev/null 2>&1 \
	&& echo "--cache-from=$(call $(IMAGE_NAME),$*,latest)" ) || true )
COPY_DOCKERFILE_IF_CHANGED=sed -e "s;VERTAG;$(VER);g" -e "s;PYVER;$*;g" $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile \
	> $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile_TMP__$* && \
	rsync -c $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile_TMP__$* $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile__$*
COMMON_BUILD=$(COPY_DOCKERFILE_IF_CHANGED) && \
	$(CNTR_BUILD) -t $(call $(IMAGE_NAME),$*,$(VER)) -t $(call $(IMAGE_NAME),$*,latest) \
	 -f $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile__$* $(CACHE_FROM) \
	 $(call $(IMAGE_NAME)_DIR,$*)
COMMON_TAG=$(CNTR_TAG) $(call $(IMAGE_NAME),$*,$(VER)) $(call $(IMAGE_NAME),$*,latest)
DO_IT= ($(COMMON_INSPECT) || ($(COMMON_PULL) && $(COMMON_TAG))) || ($(COMMON_PULL_LATEST) ; $(COMMON_BUILD) && $(COMMON_TAG))
COMMON_PULL=$(CNTR_PULL) $(call $(IMAGE_NAME),$*,$(VER))
COMMON_PULL_LATEST=$(CNTR_PULL) $(call $(IMAGE_NAME),$*,latest)
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)
PYMOR_BRANCH=master
MANYLINUXS=1 2010 2014
DISTROS = centos_8 debian_stretch debian_buster debian_bullseye
DEMO_TAGS = 0.5 master 2019.2 2020.1
