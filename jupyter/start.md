---
jupytext:
  text_representation:
   format_name: myst
jupyter:
  jupytext:
    cell_metadata_filter: -all
    formats: ipynb,myst
    main_language: python
    text_representation:
      format_name: myst
      extension: .md
      format_version: '1.3'
      jupytext_version: 1.11.2
kernelspec:
  display_name: Python 3
  name: python3
---

# pyMOR on Jupyter

This is a jupyter notebok server that already has all of pyMOR's dependencies baked in
and installs the latest pyMOR release at launch.

We can now import pyMOR and have a look at the packages that were discovered.

```{code-cell}
from pymor.core.config import config
config
```

Please note that changes to notebooks will not be permanent unless
you save them in a writable directory that is mounted from the outside
of this container.

## Learning more

As a next step, you should read our {ref}`technical_overview` which discusses the
most important concepts and design decisions behind pyMOR. You can also follow our
growing set of {doc}`tutorials`, which focus on specific aspects of pyMOR.

Should you have any problems regarding pyMOR, questions or
[feature requests](<https://github.com/pymor/pymor/issues>), do not hesitate
to contact us via
[GitHub discussions](<https://github.com/pymor/pymor/discussions>)!
