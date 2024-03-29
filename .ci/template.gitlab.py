#!/usr/bin/env python3

tpl = """

stages:
  - sanity
  - static_targets
  - parameterized_targets
  - test

{% macro only_on_simple_push() -%}
rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
      when: never
    - if: '$CI_COMMIT_TAG != null'
      when: never
    - when: on_success
{%- endmacro -%}
{% macro only_on_schedule_rule() -%}
rules:
    - if: $CI_PIPELINE_SOURCE != "schedule"
      when: never
    - when: on_success
{%- endmacro -%}
{% macro only_on_tags() -%}
rules:
    - if: '$CI_COMMIT_TAG == null'
      when: never
    - when: on_success
{%- endmacro -%}

#************ definition of base jobs *********************************************************************************#
# https://docs.gitlab.com/ee/ci/yaml/README.html#workflowrules-templates
include:
  - template: 'Workflows/Branch-Pipelines.gitlab-ci.yml'

.base:
    retry:
        max: 2
        when:
            - runner_system_failure
            - stuck_or_timeout_failure
            - api_failure

    tags:
      - amm-only_sb_dind
    variables:
      DOCKER_CLI_EXPERIMENTAL: enabled
      REGISTRY_PREFIX: $CI_REGISTRY/pymor/docker/pymor
      DIVE_VERSION: 0.10.0
      BUILDX_NO_DEFAULT_LOAD: 0

.docker_base:
    extends: .base
    before_script:
      - docker buildx create --use --name build --node build --driver docker-container --driver-opt network=host
      - docker buildx ls
      - docker buildx inspect
      - apk add make sed rsync bash git wget python3
      - wget -q https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.tar.gz \
        -O - | tar -xz -C /usr/local/bin
      - chmod +x /usr/local/bin/dive
      - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
      - docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PASSWORD docker.io

    artifacts:
        paths:
            - dive*.log

sanity:
    extends: .docker_base
    stage: sanity
    script:
        - docker ps
        - make ci_update
        - make readmes
        - make CNTR_CMD="echo docker" all
        - make IS_DIRTY

{%- for PY in pythons %}
parameterized_targets {{PY[0]}} {{PY[2:]}}:
    extends: .docker_base
    {{ only_on_simple_push() }}
    resource_group: cache_{{PY}}
    stage: parameterized_targets
    variables:
        PYVER: "{{PY}}"
    script: |
{%- for target in parameterized_targets %}
      make {{target}}_{{PY}}
{% endfor %}

parameterized_targets {{PY[0]}} {{PY[2:]}} (scheduled):
    extends: .docker_base
    {{ only_on_schedule_rule() }}
    resource_group: cache_{{PY}}
    stage: parameterized_targets
    variables:
        PYVER: "{{PY}}"
    script: |
{%- for target in parameterized_targets %}
      make DIVE_CHECK=1 VER=weekly_cron {{target}}_{{PY}}
{% endfor %}

parameterized_targets {{PY[0]}} {{PY[2:]}} (tagged):
    extends: .docker_base
    {{ only_on_tags() }}
    resource_group: cache_{{PY}}
    stage: parameterized_targets
    variables:
        PYVER: "{{PY}}"
    script: |
{%- for target in parameterized_targets %}
      make VER=$CI_COMMIT_TAG {{target}}_{{PY}}
{% endfor %}

{% endfor -%}


static_targets:
    extends: .docker_base
    {{ only_on_simple_push() }}
    resource_group: cache_{{PY}}
    stage: static_targets
    variables:
        PYVER: "{{PY}}"
    script: |
{%- for target in static_targets %}
      make {{target}}
{% endfor %}

static_targets (scheduled):
    extends: .docker_base
    {{ only_on_schedule_rule() }}
    resource_group: cache_{{PY}}
    stage: static_targets
    variables:
        PYVER: "{{PY}}"
    script: |
{%- for target in static_targets %}
      make DIVE_CHECK=1 VER=weekly_cron {{target}}
{% endfor %}

static_targets (tagged):
    extends: .docker_base
    {{ only_on_tags() }}
    resource_group: cache_{{PY}}
    stage: static_targets
    variables:
        PYVER: "{{PY}}"
    script: |
{%- for target in static_targets %}
      make VER=$CI_COMMIT_TAG {{target}}
{% endfor %}

{%- for mirror in mirror_types %}
{%- for PY in pythons %}
test {{mirror}} {{PY[0]}} {{PY[2:]}}:
    stage: test
    extends: .base
    {{ only_on_simple_push() }}
    services:
    {%- if mirror == "oldest" %}
        - name: $REGISTRY_PREFIX/pypi-mirror_oldest_py{{PY}}:$CI_COMMIT_SHA
    {%- else %}
        - name: $REGISTRY_PREFIX/pypi-mirror_stable_py{{PY}}:$CI_COMMIT_SHA
    {%- endif %}
          alias: pypi_mirror
    image: $REGISTRY_PREFIX/testing_py{{PY}}:$CI_COMMIT_SHA
    script:
        - ./.ci/test.bash

test compose {{mirror}} {{PY[0]}} {{PY[2:]}}:
    stage: test
    extends: .base
    {{ only_on_simple_push() }}
    resource_group: compose
    needs: ["parameterized_targets {{PY[0]}} {{PY[2:]}}"]
    script:
        - echo DISABLED make pypi-mirror_test_{{PY}}

test {{mirror}} {{PY[0]}} {{PY[2:]}} (tagged):
    stage: test
    extends: .base
    {{ only_on_tags() }}
    services:
    {%- if mirror == "oldest" %}
        - name: $REGISTRY_PREFIX/pypi-mirror_oldest_py{{PY}}:$CI_COMMIT_TAG
    {%- else %}
        - name: $REGISTRY_PREFIX/pypi-mirror_stable_py{{PY}}:$CI_COMMIT_TAG
    {%- endif %}
          alias: pypi_mirror
    image: $REGISTRY_PREFIX/testing_py{{PY}}:$CI_COMMIT_TAG
    script:
        - ./.ci/test.bash

test compose {{mirror}} {{PY[0]}} {{PY[2:]}} (tagged):
    stage: test
    extends: .base
    {{ only_on_tags() }}
    resource_group: compose
    needs: ["parameterized_targets {{PY[0]}} {{PY[2:]}} (tagged)"]
    script:
        - echo DISABLED make VER=$CI_COMMIT_TAG pypi-mirror_test_{{PY}}

{% endfor %}
{% endfor %}

{%- for PY in pythons %}
main rebuild {{PY[0]}} {{PY[2:]}} (scheduled):
    extends: .docker_base
    {{ only_on_schedule_rule() }}
    resource_group: cache_{{PY}}
    needs: [sanity]
    stage: parameterized_targets
    variables:
        PYVER: "{{PY}}"
    script: |
      wget https://raw.githubusercontent.com/pymor/pymor/main/.env -O pymor.env
      source pymor.env
      set -u
      git checkout ${CI_IMAGE_TAG}
{% if loop.first %}
{%- for target in static_targets %}
      make VER=${CI_IMAGE_TAG} {{target}}
{% endfor %}
{% endif %}
      make VER=${CI_IMAGE_TAG} {{PY}}
{% endfor -%}

# THIS FILE IS AUTOGENERATED -- DO NOT EDIT #
#   Edit and Re-run template.ci.py instead       #

"""


import jinja2
from pathlib import Path

tpl = jinja2.Template(tpl)
pythons = ["3.8", "3.9", "3.10"]
static_targets = [
    "docker-in-docker",
    "demo_main",
    "deploy_checks",
    "ci_sanity",
    "devpi",
]
mirror_types = ["oldest", "stable"]
parameterized_targets = [
    "python_builder",
    "python",
    "constraints",
    "dealii",
    "petsc",
    "dolfinx",
    "pypi-mirror_stable",
    "pypi-mirror_oldest",
    "ngsolve",
    "fenics",
    "precice",
] + ["cibase", "testing", "jupyter", "minimal_cibase", "minimal_testing"]

with open(Path(__file__).resolve().parent / "gitlab-ci.yml", "wt") as yml:
    yml.write(tpl.render(**locals()))
