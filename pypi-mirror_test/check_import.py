#!/usr/bin/env python3

import pkgutil
from importlib import import_module

for f in pkgutil.iter_modules():
    print(f"importing {f}")
    print(f"importing {f[0]}")
    if f[0].path.startswith("/usr/local/bin"):
        continue
    import_module(f[1])
