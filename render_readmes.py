#!/usr/bin/env python3

from pathlib import Path
import sys
from typing import List

from jinja2 import Environment, FileSystemLoader, select_autoescape


THIS_DIR = Path(__file__).resolve().absolute().parent


def render_readme(tpl_path: Path, pythons: List[str]):
    env = Environment(
        loader=FileSystemLoader(str(THIS_DIR)), autoescape=select_autoescape()
    )
    template = env.get_template(str(tpl_path.relative_to(THIS_DIR)))
    out_path = tpl_path.parent / "README.md"
    out_path.write_text(
        template.render(
            pythons=pythons, image_dir=tpl_path.parent.relative_to(THIS_DIR)
        )
    )


if __name__ == "__main__":
    pythons = sys.argv[1].split()
    for tpl in THIS_DIR.glob("**/image_readme.jinja"):
        render_readme(tpl, pythons)
