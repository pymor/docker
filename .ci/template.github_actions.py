#!/usr/bin/env python3

tpl = """
{% macro login() -%}
        - name: Dockerhub Login
          uses: docker/login-action@v1
          with:
              registry: docker.io
              username: {% raw %}${{ secrets.DH_USER }}{% endraw %}
              password: {% raw %}${{ secrets.DH_PW }}{% endraw %}
        - name: Zivgitlab Login
          uses: docker/login-action@v1
          with:
              registry: zivgitlab.wwu.io/pymor/docker
              username: {% raw %}${{ secrets.ZIV_USER }}{% endraw %}
              password: {% raw %}${{ secrets.ZIV_PW }}{% endraw %}
{% endmacro %}

name: Docker build

on:
    push:
    schedule:
        - cron: "0 1 * * 0"

jobs:
    bugout:
        runs-on: ubuntu-20.04
        steps:
        - name: Cancel Previous Runs
          uses: styfle/cancel-workflow-action@0.9.1
          with:
              all_but_latest: true
              # also works on 'pull_request' targets
              ignore_sha: true
              access_token: {% raw %}${{ github.token }}{% endraw %}
    static:
        runs-on: self-hosted
        concurrency:
          group: static
        steps:
        {{ login() }}
        - uses: actions/checkout@v2
        - name: build
          run: |
{%- for target in static_targets %}
            make {{target}}
            wait
            make push_{{target}} &
{% endfor %}
            wait

{%- for PY in pythons %}
    parameterized_{{PY[0]}}_{{PY[2:]}}:
        name: Python {{PY}}
        runs-on: self-hosted
        needs: static
        concurrency:
          group: param_{{PY}}
        env:
            PYVER: "{{PY}}"
        steps:
        {{ login() }}
        - uses: actions/checkout@v2
{%- for target in parameterized_targets %}
        - name: {{target}}_{{PY}}
          run: |
            make {{target}}_{{PY}}
            # wait for potentially running push
            wait
            make push_{{target}}_{{PY}} &
{% endfor %}
        - name: finalize push
          run: |
            wait
{% endfor %}

    test_compose:
        needs:
        {%- for PY in pythons %}
        - parameterized_{{PY[0]}}_{{PY[2:]}}
        {%- endfor %}
        runs-on: self-hosted
        steps:
        # this checks both oldest+stable mirror variants
        - name: test_{{PY}}
          run: make pypi-mirror_test


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
    "docs",
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

THIS_DIR = Path(__file__).resolve().parent
with open(THIS_DIR / ".." / ".github" / "workflows" / "docker_build.yml", "wt") as yml:
    yml.write(tpl.render(**locals()))
