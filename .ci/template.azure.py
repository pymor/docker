#!/usr/bin/env python3

tpl = """# THIS FILE IS AUTOGENERATED -- DO NOT EDIT #
#   Edit and Re-run template.ci.py instead       #

#************ definition of base jobs *********************************************************************************#

{% macro pyjob(name, stage) -%}
{%- for PY in pythons %}
    - job: {{ name.replace('-', '__') }}_{{PY.replace('.', '_')}}
      timeoutInMinutes: 0
      pool:
        vmImage: 'ubuntu-16.04'
      variables:
        DOCKER_CLI_EXPERIMENTAL: enabled
        DOCKER_BUILDKIT: 1
      steps:
        - checkout: self
          submodules: true
        - script: |
            echo '{"experimental": true}' | sudo tee /etc/docker/daemon.json
            sudo systemctl restart docker
            docker version
            docker system prune -af
            sudo rm -rf /opt/{google,cabal,microsoft,mssql-tools,ghc,hhvm,AGPM,hostedtoolcache} /usr/man /usr/local/man /usr/local/julia*
          displayName: "setup docker & remove unused packages"
        - task: Docker@2
          displayName: Container registry login
          inputs:
            command: login
            containerRegistry: dockerhub
        - script: |
            make {{name}}_{{PY}} ||  sleep 5 ; make {{name}}_{{PY}}
            make push_{{name}}_{{PY}} || sleep 5 ; make push_{{name}}_{{PY}}
{% endfor -%}
{%- endmacro %}

{% macro job(name, stage) %}
    - job: {{name.replace('-', '__')}}
      timeoutInMinutes: 0
      pool:
        vmImage: 'ubuntu-16.04'
      variables:
        DOCKER_CLI_EXPERIMENTAL: enabled
        DOCKER_BUILDKIT: 1
      steps:
        - checkout: self
          submodules: true
        - script: |
            echo '{"experimental": true}' | sudo tee /etc/docker/daemon.json
            sudo systemctl restart docker
            docker system prune -af
            sudo rm -rf /opt/{google,cabal,microsoft,mssql-tools,ghc,hhvm,AGPM,hostedtoolcache} /usr/man /usr/local/man /usr/local/julia*
            docker version
          displayName: "setup docker & remove unused packages"
        - task: Docker@2
          displayName: Container registry login
          inputs:
            command: login
            containerRegistry: dockerhub
        - script: |
            make {{name}} || sleep 5 ; make {{name}}
            make push_{{name}} || sleep 5 ; make push_{{name}}
{%- endmacro %}

{% macro stage(name) %}
  - stage: s_{{name}}
    displayName: {{name}}
    jobs:

{%- endmacro %}

stages:
{{ stage(0) }}
{{ pyjob('python_builder', 0)}}
{{ job('deploy_checks', 0)}}

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

{{ stage(6) }}
{{ pyjob('jupyter', 6)}}
{{ job('docker-in-docker', 6)}}
{{ job('docs', 6)}}

# THIS FILE IS AUTOGENERATED -- DO NOT EDIT #
#   Edit and Re-run template.ci.py instead       #

"""


import os
import jinja2
import sys
from itertools import product
from pathlib import Path

tpl = jinja2.Template(tpl)
pythons = ["3.6", "3.7", "3.8", "3.9"]
manylinux = ["1", "2010", "2014"]

with open(os.path.join(os.path.dirname(__file__), "azure-pipeline.yml"), "wt") as yml:
    yml.write(tpl.render(**locals()))
