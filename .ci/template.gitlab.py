#!/usr/bin/env python3

tpl = '''

stages:
  - "0"
  - "1"
  - "2"
  - "3"
  - "4"
  - "5"
  - "6"

#************ definition of base jobs *********************************************************************************#

.per_py:
    retry:
        max: 2
        when:
            - runner_system_failure
            - stuck_or_timeout_failure
            - api_failure

    tags:
      - amm-only_shell
    script:
      - make ${TARGET}_${PYVER}
      - make push_${TARGET}_${PYVER}
      - docker version
      - docker buildx

.py_indep:
    extends: .per_py
    script:
      - make ${TARGET}
      - make push_${TARGET}

{% macro pyjob(name, stage) -%}
{%- for PY in pythons %}
{{name}} {{PY[0]}} {{PY[2]}}:
    extends: .per_py
    stage: "{{stage}}"
    variables:
        PYVER: "{{PY}}"
        TARGET: {{name}}
{% endfor -%}
{%- endmacro %}

{% macro job(name, stage) -%}
{{name}}:
    extends: .py_indep
    stage: "{{stage}}"
    variables:
        TARGET: {{name}}
{%- endmacro %}

#******* stage 0
{{ pyjob('python_builder', 0)}}
{{ job('deploy_checks', 0)}}

#******* stage 1
{{ job('ci_sanity', 1) }}
{{ pyjob('python', 1)}}

#******* stage 2
{{ pyjob('constraints', 2)}}
{{ pyjob('dealii', 2)}}
{{ pyjob('petsc', 2)}}

#******* stage 3
{{ pyjob('pypi-mirror_stable', 3)}}
{{ pyjob('pypi-mirror_oldest', 3)}}
{{ pyjob('ngsolve', 3)}}
{{ pyjob('fenics', 3)}}

#******* stage 4
{%- for ml in manylinux %}
{%- set wml -%}
    wheelbuilder_manylinux{{ml}}
{%- endset -%}
{{ pyjob(wml, 4)}}
{% endfor %}
{{ pyjob('cibase', 4)}}

#******* stage 5
{{ pyjob('testing', 5)}}
{{ job('demo_master', 5)}}

#******* stage 6
{{ pyjob('jupyter', 6)}}
{{ job('docker-in-docker', 6)}}
{{ job('docs', 6)}}

# THIS FILE IS AUTOGENERATED -- DO NOT EDIT #
#   Edit and Re-run template.ci.py instead       #

'''


import os
import jinja2
import sys
from itertools import product
from pathlib import Path

tpl = jinja2.Template(tpl)
pythons = ['3.6', '3.7', '3.8']
manylinux = ['2010', '2014']

with open(os.path.join(os.path.dirname(__file__), 'gitlab-ci.yml'), 'wt') as yml:
    yml.write(tpl.render(**locals()))
