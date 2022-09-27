PYTHONS = 3.8 3.9
VER?=$(shell git log -1 --pretty=format:"%H")
NGSOLVE_IMAGE = pymor/ngsolve_py$1:$2
NGSOLVE_IMAGE_DIR = ngsolve/docker
PETSC_IMAGE = pymor/petsc_py$1:$2
PETSC_IMAGE_DIR = petsc/docker
PRECICE_IMAGE = pymor/precice_py$1:$2
PRECICE_IMAGE_DIR = precice
PYTHON_IMAGE = pymor/python_$1:$2
PYTHON_IMAGE_DIR = python
PYTHON_BUILDER_IMAGE = pymor/python_builder_$1:$2
PYTHON_BUILDER_IMAGE_DIR = python_builder/$1/bullseye/slim
FENICS_IMAGE = pymor/fenics_py$1:$2
FENICS_IMAGE_DIR = fenics/docker
DOLFINX_IMAGE = pymor/dolfinx_py$1:$2
DOLFINX_IMAGE_DIR = dolfinx/docker
DEALII_IMAGE = pymor/dealii_py$1:$2
DEALII_IMAGE_DIR = dealii/docker
CIBASE_IMAGE = pymor/cibase_py$1:$2
CIBASE_IMAGE_DIR = cibase/bullseye
MINIMAL_CIBASE_IMAGE = pymor/minimal_cibase_py$1:$2
MINIMAL_CIBASE_IMAGE_DIR = minimal_cibase/bullseye
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
CI_SANITY_IMAGE = pymor/ci_sanity:$2
CI_SANITY_IMAGE_DIR = ci_sanity
CONSTRAINTS_IMAGE = pymor/constraints_py$1:$2
CONSTRAINTS_IMAGE_DIR = constraints
DEPLOY_CHECKS_IMAGE = pymor/deploy_checks_$1:$2
DEPLOY_CHECKS_IMAGE_DIR = deploy_checks/$1
JUPYTER_IMAGE = pymor/jupyter_py$1:$2
JUPYTER_IMAGE_DIR = jupyter
MIRROR_TEST_IMAGE = pymor/pypi-mirror_test_py$1:$2
MIRROR_TEST_IMAGE_DIR = pypi-mirror_test

MAIN_CNTR_REGISTRY?=zivgitlab.wwu.io/pymor/docker
ALT_CNTR_REGISTRY?=docker.io
CNTR_CMD?=docker
ifeq ($(CI),1)
	PROGRESS=--progress=plain
endif

# there's a bug in the buildx code atm where with the container driver
# where `type=image` only loads the image if `push=true`
# Otherwise we'd want to set `push=$(CI)==1`
ifeq ($(shell docker buildx inspect | grep Driver | cut -f 2 -d ' '),docker-container)
	BUILDX_OUTPUT=--output type=image,push=true
else
	BUILDX_OUTPUT=--output type=image,push=false
endif

CNTR_BUILD=$(CNTR_CMD) buildx build $(PROGRESS)
CNTR_TAG=$(CNTR_CMD) tag
CNTR_PUSH=$(CNTR_CMD) push
CNTR_PULL=$(CNTR_CMD) pull -q
CNTR_RUN=$(CNTR_CMD) run
CNTR_RMI=$(CNTR_CMD) rmi -f
CNTR_INSPECT=$(CNTR_CMD) inspect
FULL_IMAGE_NAME = $(MAIN_CNTR_REGISTRY)/$(call $(IMAGE_NAME),$1,$2)
FULL_IMAGE_NAME_NO_TAG = $(subst :replaceme,,$(MAIN_CNTR_REGISTRY)/$(call $(IMAGE_NAME),$1,replaceme))
ALT_IMAGE_NAME = $(ALT_CNTR_REGISTRY)/$(call $(IMAGE_NAME),$1,$2)
COMMON_INSPECT=$(CNTR_INSPECT) $(call FULL_IMAGE_NAME,$1,$(VER)) >/dev/null 2>&1
CACHE_FROM=--cache-from=type=registry,ref=$(call FULL_IMAGE_NAME_NO_TAG,$1)
CACHE_TO=--cache-to=type=registry,mode=max,ref=$(call FULL_IMAGE_NAME_NO_TAG,$1)
COPY_DOCKERFILE_IF_CHANGED=sed -f macros.sed $(call $(IMAGE_NAME)_DIR,$1)/Dockerfile \
	> $(call $(IMAGE_NAME)_DIR,$1)/Dockerfile_TMP__$1 && \
	sed -i -e "s;VERTAG;$(VER);g" -e "s;PYVER;$1;g" -e "s;REGISTRY;$(MAIN_CNTR_REGISTRY);g" $(call $(IMAGE_NAME)_DIR,$1)/Dockerfile_TMP__$1 && \
	rsync -c $(call $(IMAGE_NAME)_DIR,$1)/Dockerfile_TMP__$1 $(call $(IMAGE_NAME)_DIR,$1)/Dockerfile__$1
COMMON_BUILD=\
	$(COPY_DOCKERFILE_IF_CHANGED) \
	&& \
	$(CNTR_BUILD) --tag $(call FULL_IMAGE_NAME,$1,$(VER)) --tag $(call FULL_IMAGE_NAME,$1,latest) \
		--tag $(call ALT_IMAGE_NAME,$1,$(VER)) --tag $(call ALT_IMAGE_NAME,$1,latest) \
		-f $(call $(IMAGE_NAME)_DIR,$1)/Dockerfile__$1 $(CACHE_FROM) $(CACHE_TO) \
		$(BUILDX_OUTPUT) \
		$(call $(IMAGE_NAME)_DIR,$1)
COMMON_TAG=$(CNTR_TAG) $(call FULL_IMAGE_NAME,$1,$(VER)) $(call FULL_IMAGE_NAME,$1,latest)
DIVE_LOG=$(subst /,__,dive_$(call $(IMAGE_NAME),$1,$2).log)
CHECK_IMG=([ "$(DIVE_CHECK)" = "1" ] \
	&& which dive 2>&1 \
	&& CI=true dive $(call FULL_IMAGE_NAME,$*,$(VER)) > $(call DIVE_LOG,$*,$(VER)) 2>&1) || true
DO_IT_ARG= \
	echo "Building $(call FULL_IMAGE_NAME,$1,$(VER))" ; \
	$(call COMMON_BUILD,$1) \
	&& $(CHECK_IMG)
DO_IT=$(call DO_IT_ARG,$*)
DO_IT_NOARG=$(call DO_IT_ARG,NONE)
COMMON_PULL=$(CNTR_PULL) $(call FULL_IMAGE_NAME,$1,$(VER))
COMMON_PULL_LATEST=$(CNTR_PULL) $(call FULL_IMAGE_NAME,$1,latest)
COMMON_PUSH=$(CNTR_PUSH) $(call FULL_IMAGE_NAME,$1,$(VER)) && \
	$(CNTR_PUSH) $(call FULL_IMAGE_NAME,$1,latest) && \
	$(CNTR_PUSH) $(call ALT_IMAGE_NAME,$1,$(VER)) && \
	$(CNTR_PUSH) $(call ALT_IMAGE_NAME,$1,latest)
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)
PYMOR_BRANCH=main
MANYLINUXS=2010 2014
DEMO_TAGS = 0.5 main 2019.2 2020.1 2020.2 2021.1 2021.2 2022.1
