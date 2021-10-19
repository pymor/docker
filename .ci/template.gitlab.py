#!/usr/bin/env python3

tpl = """

stages:
  - static_targets
  - parameterized_targets
  - test

{% macro never_on_schedule_rule() -%}
rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
      when: never
    - when: on_success
{%- endmacro -%}
{% macro only_on_schedule_rule() -%}
rules:
    - if: $CI_PIPELINE_SOURCE != "schedule"
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

.docker_base:
    extends: .base
    before_script:
      - docker buildx --help
      - apk add make sed rsync bash git
      - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
      - docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PASSWORD docker.io

{%- for PY in pythons %}
parameterized_targets {{PY[0]}} {{PY[2]}}:
    extends: .docker_base
    {{ never_on_schedule_rule() }}
    resource_group: cache_{{PY}}
    stage: parameterized_targets
    variables:
        PYVER: "{{PY}}"
    script:
{%- for target in parameterized_targets %}
      - make {{target}}_{{PY}}
      # wait for potentially running push
      - wait
      - make push_{{target}}_{{PY}} &
{% endfor %}
      - wait
{% endfor -%}

{%- for PY in pythons %}
parameterized_targets {{PY[0]}} {{PY[2]}} (scheduled):
    extends: .docker_base
    {{ only_on_schedule_rule() }}
    resource_group: cache_{{PY}}
    stage: parameterized_targets
    variables:
        PYVER: "{{PY}}"
    script:
{%- for target in parameterized_targets %}
      - make VER=weekly_cron {{target}}_{{PY}}
      # wait for potentially running push
      - wait
      - make VER=weekly_cron push_{{target}}_{{PY}} &
{% endfor %}
      - wait
{% endfor -%}


static_targets:
    extends: .docker_base
    {{ never_on_schedule_rule() }}
    resource_group: cache_{{PY}}
    stage: static_targets
    variables:
        PYVER: "{{PY}}"
    script:
{%- for target in static_targets %}
      - make {{target}}
      - wait
      - make push_{{target}} &
{% endfor %}
      - wait

static_targets (scheduled):
    extends: .docker_base
    {{ only_on_schedule_rule() }}
    resource_group: cache_{{PY}}
    stage: static_targets
    variables:
        PYVER: "{{PY}}"
    script:
{%- for target in static_targets %}
      - make VER=weekly_cron {{target}}
      - wait
      - make VER=weekly_cron push_{{target}} &
{% endfor %}
      - wait

{%- for mirror in mirror_types %}
{%- for PY in pythons[1:] %}
test {{mirror}} {{PY[0]}} {{PY[2]}}:
    stage: test
    extends: .base
    {{ never_on_schedule_rule() }}
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
{% endfor %}
{% endfor %}

# THIS FILE IS AUTOGENERATED -- DO NOT EDIT #
#   Edit and Re-run template.ci.py instead       #

"""


import os
import jinja2
import sys
from itertools import product
from pathlib import Path

tpl = jinja2.Template(tpl)
pythons = ["3.7", "3.8", "3.9"]
static_targets = [
    "docker-in-docker",
    "demo_main",
    "deploy_checks",
    "ci_sanity",
    "devpi",
]
mirror_types = ["oldest", "stable"]
parameterized_targets = (
    [
        "python_builder",
        "python",
        "constraints",
        "dealii",
        "petsc",
        "pypi-mirror_stable",
        "pypi-mirror_oldest",
        "ngsolve",
        "fenics",
        "openfoam",
        "precice",
    ]
    + ["cibase", "testing", "jupyter", "minimal_cibase", "minimal_testing"]
)

with open(os.path.join(os.path.dirname(__file__), "gitlab-ci.yml"), "wt") as yml:
    yml.write(tpl.render(**locals()))
