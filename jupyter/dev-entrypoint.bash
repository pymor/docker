#!/bin/bash

[[ -d /pymor ]] && cd /pymor

exec "${@}"
