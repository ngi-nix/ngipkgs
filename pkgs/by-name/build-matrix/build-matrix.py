#! /usr/bin/env python3

from json import dump, loads
from networkx import (
    DiGraph,
    induced_subgraph,
    lexicographical_topological_sort,
    weakly_connected_components,
)
from sys import argv, stdin, stdout


def system_to_platform(system: str) -> list[str]:
    return {
        "x86_64-linux": ["ubuntu-22.04"],
        "x86_64-darwin": ["macos-12"],
    }[system]


assert 2 == len(argv)

G = DiGraph()


def path(v: str) -> str:
    return argv[1] + "." + ".".join(f'"{x}"' for x in G.nodes[v]["attrPath"])


def name(v: str) -> str:
    return G.nodes[v]["name"]


for line in stdin:
    attr = loads(line)
    if not attr["isCached"]:
        G.add_node(attr["drvPath"], **attr)

for u in G.nodes:
    for v in G.nodes[u]["inputDrvs"]:
        if v in G.nodes:
            G.add_edge(u, v)

result = {"include": []}
for nodes in weakly_connected_components(G):
    g = list(lexicographical_topological_sort(induced_subgraph(G, nodes)))
    result["include"].append(
        {
            "attributes": list(map(path, g)),
            "names": list(map(name, g)),
            "platform": system_to_platform(G.nodes[g[0]]["system"]),
        }
    )

dump(result, stdout)
