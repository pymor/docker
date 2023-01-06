#!/usr/bin/env python
from collections import defaultdict
from pathlib import Path
import sys
from xml.dom.minidom import parse, Node

import pydot as pydot


def process_gefx(infile: Path) -> (dict, dict):
    document = parse(infile.open())
    graph = document.getElementsByTagName("graph")[0]
    nodes_root = graph.getElementsByTagName("nodes")[0]
    nodes = dict()
    for node in nodes_root.getElementsByTagName("node"):
        label = node.getAttribute("label")

        nodes[node.getAttribute("id")] = label
    edges = defaultdict(list)
    for edge in graph.getElementsByTagName("edges")[0].getElementsByTagName("edge"):
        edges[edge.getAttribute("source")].append(edge.getAttribute("target"))
    return nodes, edges


def process_dot(infile: Path):
    graphs = pydot.graph_from_dot_file(infile)
    if graphs is None:
        raise ValueError(f"No graph found in {infile}")
    graph = graphs[0]
    edges = defaultdict(list)
    nodes = dict()
    for node in graph.get_nodes():
        nodes[node.get_name()] = node.get_label()
    for edge in graph.get_edges():
        edges[edge.get_source()].append(edge.get_destination())
    return nodes, edges


def write_mermaid(nodes: dict, edges: dict, outfile: Path):
    with outfile.open("w") as f:
        f.write("flowchart TD\n")
        for fro, to_list in edges.items():
            for to in to_list:
                f.write(f"    {nodes[fro]} --> {nodes[to]}\n")


if __name__ == "__main__":
    infile = Path(sys.argv[1])
    try:
        nodes, edges = process_gefx(infile=infile)
    except:
        nodes, edges = process_dot(infile=infile)
    write_mermaid(nodes=nodes, edges=edges, outfile=infile.with_suffix(".mmd"))
