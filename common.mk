PYTHONS = 3.7 3.8 3.9
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
DOLFINX_IMAGE = pymor/dolfinx_py$1:$2
DOLFINX_IMAGE_DIR = dolfinx/docker
DEALII_IMAGE = pymor/dealii_py$1:$2
DEALII_IMAGE_DIR = dealii/docker
CIBASE_IMAGE = pymor/cibase_py$1:$2
CIBASE_IMAGE_DIR = cibase/buster
MINIMAL_CIBASE_IMAGE = pymor/minimal_cibase_py$1:$2
MINIMAL_CIBASE_IMAGE_DIR = minimal_cibase/buster
DIND_IMAGE = pymor/docker-in-docker:$2
DIND_IMAGE_DIR = docker-in-docker
DEVPI_IMAGE = pymor/devpi:$2
DEVPI_IMAGE_DIR = devpi
TESTING_IMAGE = pymor/testing_py$1:$2
TESTING_IMAGE_DIR = testing/$1
MINIMAL_TESTING_IMAGE = pymor/minimal_testing_py$1:$2
MINIMAL_TESTING_IMAGE_DIR = minimal_testing/$1
PYPI_MIRROR_OLDEST_IMAGE = pymor/pypi-mirror_oldest_py$1:$2
PYPI_MIRROR_OLDEST_IMAGE_DIR = pypi-mirror_oldest
PYPI_MIRROR_STABLE_IMAGE = pymor/pypi-mirror_stable_py$1:$2
PYPI_MIRROR_STABLE_IMAGE_DIR = pypi-mirror_stable
CI_WHEELS_IMAGE = pymor/ci_wheels_py$1:$2
CI_WHEELS_IMAGE_DIR = ci_wheels
CONSTRAINTS_IMAGE = pymor/constraints_py$1:$2
CONSTRAINTS_IMAGE_DIR = constraints
DOC_RELEASES_IMAGE = pymor/doc_releases:$2
DOC_RELEASES_IMAGE_DIR = docs
JUPYTER_IMAGE = pymor/jupyter_py$1:$2
JUPYTER_IMAGE_DIR = jupyter
MIRROR_TEST_IMAGE = pymor/pypi-mirror_test_py$1:$2
MIRROR_TEST_IMAGE_DIR = pypi-mirror_test
WB2010_IMAGE = pymor/wheelbuilder_manylinux2010_py$1:$2
WB2010_IMAGE_DIR = wheelbuilder_manylinux2010
WB2014_IMAGE = pymor/wheelbuilder_manylinux2014_py$1:$2
WB2014_IMAGE_DIR = wheelbuilder_manylinux2014
# CNTR_BUILD=$(CNTR_CMD) build --squash
MAIN_CNTR_REGISTRY?=zivgitlab.wwu.io/pymor/docker
ALT_CNTR_REGISTRY?=docker.io
CNTR_CMD?=docker
ifeq ($(CI),1)
	PROGRESS="--progress=plain"
endif
# this makes produced images usable by '--cache-from'
CNTR_BUILD=$(CNTR_CMD) buildx build --build-arg BUILDKIT_INLINE_CACHE=1 $(PROGRESS)
CNTR_TAG=$(CNTR_CMD) tag
CNTR_PUSH=$(CNTR_CMD) push
CNTR_PULL=$(CNTR_CMD) pull -q
CNTR_RUN=$(CNTR_CMD) run
CNTR_RMI=$(CNTR_CMD) rmi -f
CNTR_INSPECT=$(CNTR_CMD) inspect
FULL_IMAGE_NAME = $(MAIN_CNTR_REGISTRY)/$(call $(IMAGE_NAME),$1,$2)
ALT_IMAGE_NAME = $(ALT_CNTR_REGISTRY)/$(call $(IMAGE_NAME),$1,$2)
COMMON_INSPECT=$(CNTR_INSPECT) $(call FULL_IMAGE_NAME,$*,$(VER)) >/dev/null 2>&1
CACHE_FROM=$$( ($(CNTR_INSPECT) $(call FULL_IMAGE_NAME,$*,latest) >/dev/null 2>&1 \
	&& echo "--cache-from=$(call FULL_IMAGE_NAME,$*,latest)" ) || true )
COPY_DOCKERFILE_IF_CHANGED=sed -f macros.sed $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile \
	> $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile_TMP__$* && \
	sed -i -e "s;VERTAG;$(VER);g" -e "s;PYVER;$*;g" -e "s;REGISTRY;$(MAIN_CNTR_REGISTRY);g" $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile_TMP__$* && \
	rsync -c $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile_TMP__$* $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile__$*
COMMON_BUILD=$(COPY_DOCKERFILE_IF_CHANGED) && \
	$(CNTR_BUILD) -t $(call FULL_IMAGE_NAME,$*,$(VER)) -t $(call FULL_IMAGE_NAME,$*,latest) \
	-t $(call ALT_IMAGE_NAME,$*,$(VER)) -t $(call ALT_IMAGE_NAME,$*,latest) \
	 -f $(call $(IMAGE_NAME)_DIR,$*)/Dockerfile__$* $(CACHE_FROM) \
	 $(call $(IMAGE_NAME)_DIR,$*)
COMMON_TAG=$(CNTR_TAG) $(call FULL_IMAGE_NAME,$*,$(VER)) $(call FULL_IMAGE_NAME,$*,latest)
DO_IT= ($(COMMON_INSPECT) || ($(COMMON_PULL) && $(COMMON_TAG))) || ($(COMMON_PULL_LATEST) ; $(COMMON_BUILD) && $(COMMON_TAG))
COMMON_PULL=$(CNTR_PULL) $(call FULL_IMAGE_NAME,$*,$(VER))
COMMON_PULL_LATEST=$(CNTR_PULL) $(call FULL_IMAGE_NAME,$*,latest)
COMMON_PUSH=$(CNTR_PUSH) $(call FULL_IMAGE_NAME,$1,$(VER)) && \
	$(CNTR_PUSH) $(call FULL_IMAGE_NAME,$1,latest) && \
	$(CNTR_PUSH) $(call ALT_IMAGE_NAME,$1,$(VER)) && \
	$(CNTR_PUSH) $(call ALT_IMAGE_NAME,$1,latest)
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)
PYMOR_BRANCH=main
MANYLINUXS=2010 2014
DEMO_TAGS = 0.5 main 2019.2 2020.1 2021.1
