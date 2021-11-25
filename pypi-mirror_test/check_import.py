#!/usr/bin/env python3

import pkgutil
from importlib import import_module

for f in pkgutil.iter_modules():
    import_module(f[1])
