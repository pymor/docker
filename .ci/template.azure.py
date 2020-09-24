#!/usr/bin/env python3

tpl = '''# THIS FILE IS AUTOGENERATED -- DO NOT EDIT #
#   Edit and Re-run template.ci.py instead       #

#************ definition of base jobs *********************************************************************************#

{% macro pyjob(name, stage) -%}
{%- for PY in pythons %}
    - job: {{ name.replace('-', '__') }}_{{PY.replace('.', '_')}}
      timeoutInMinutes: 0
      pool:
        vmImage: 'ubuntu-16.04'
      steps:
        - checkout: self
          submodules: true
        - task: Docker@2
          displayName: Container registry login
          inputs:
            command: login
            containerRegistry: dockerhub
        - script: |
            docker system prune -af
            make {{name}}_{{PY}}
            make push_{{name}}_{{PY}}
{% endfor -%}
{%- endmacro %}

{% macro job(name, stage) %}
    - job: {{name.replace('-', '__')}}
      timeoutInMinutes: 0
      pool:
        vmImage: 'ubuntu-16.04'
      steps:
        - checkout: self
          submodules: true
        - task: Docker@2
          displayName: Container registry login
          inputs:
            command: login
            containerRegistry: dockerhub
        - script: |
            make {{name}}
            make push_{{name}}
{%- endmacro %}

{% macro stage(name) %}
  - stage: s_{{name}}
    displayName: {{name}}
    jobs:

{%- endmacro %}

stages:
{{ stage(0) }}
{{ pyjob('python_builder', 0)}}

{{ stage(1) }}
{{ job('ci_sanity', 1) }}
{{ pyjob('python', 1)}}

{{ stage(2) }}
{{ pyjob('constraints', 2)}}
{{ pyjob('dealii', 2)}}
{{ pyjob('petsc', 2)}}

{{ stage(3) }}
{{ pyjob('pypi-mirror_stable', 3)}}
{{ pyjob('pypi-mirror_oldest', 3)}}
{{ pyjob('ngsolve', 3)}}
{{ pyjob('fenics', 3)}}

{{ stage(4) }}
{%- for ml in manylinux %}
{%- set wml -%}
    wheelbuilder_manylinux{{ml}}
{%- endset -%}
{{ pyjob(wml, 4)}}
{% endfor %}
{{ pyjob('cibase', 4)}}

{{ stage(5) }}
{{ pyjob('testing', 5)}}
{{ job('demo_master', 5)}}
{{ job('deploy_checks', 5)}}

{{ stage(6) }}
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
manylinux = ['1', '2010', '2014']

with open(os.path.join(os.path.dirname(__file__), 'azure-pipeline.yml'), 'wt') as yml:
    yml.write(tpl.render(**locals()))
