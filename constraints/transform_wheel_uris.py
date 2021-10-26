#!/usr/bin/env python3

from wheel_filename import parse_wheel_filename as pwf
import sys
from pathlib import Path

input = Path(sys.argv[1])
target_fn = input.parent / f"transformed_{input.name}"

with open(target_fn, "wt") as out:
    for line in open(input).readlines():
        line = line.strip()
        if "file:///ci_wheels" in line:
            line = line.replace("%2B", "+")
            pkg = pwf(line)
            line = f"{pkg.project}=={pkg.version}"
        out.write(f"{line}\n")
