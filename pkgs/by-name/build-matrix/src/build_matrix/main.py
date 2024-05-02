#! /usr/bin/env python3

from json import dump, loads
from networkx import (
    DiGraph,
    induced_subgraph,
    lexicographical_topological_sort,
    weakly_connected_components,
)
from sys import argv, stdin, stdout

"""
This script reads JSON Lines in the output format of `nix-eval-jobs`,
and produces a JSON object that defines a job matrix for GitHub Actions.
The core requirement is **grouping derivations into jobs**.
It is much more useful to build derivations that depend on each other
in one job, rather than spawning one job per derivation, which will
lead to duplicated work: If A depends on B, and we assign job 1 to build A
and job 2 to build B, then jobs 1 and 2 will **both** build (and race for) B.
Instead, we detect these dependencies and have only one job that builds both.
We construct a DAG, where A → B iff A depends on B, and then find
(weakly) connected components, each of which induces a subgraph
representing one build job.
We name the build job using names of the derivations in the job,
in topological order breaking ties lexicographically.
Add two more derivations to our example, C, which also depends on B, and D
with no dependencies. We now have

    V  = { A, B, C, D }    and    E  = { A → B, C → D }

The two connected components are

    C₁ = { A, B, C    }    and    C₂ = { D }

There is one topological order for C₂ (trivial), and two for C₁:

    O₁ = [ C < A < B ]     and O₂ = [ A < C < B ]

Breaking ties lexicographically results in O₂.

Note that the input will contain dependencies that are not in the set
of "interesting" derivations, e.g. they are not declared in our flake,
but in Nixpkgs. We ignore such derivations for our analysis.
Further, if `nix-eval-jobs` is invoked with `--check-cache-status`,
then we can additionally ignore derivations that are already cached.

Following properties of the input objects are processed.

For dependency analysis:
 - `drvPath`, the store path that is produced, acts as identifier.
 - `inputDrvs`, the store paths that are required as inputs,
   i.e. dependencies, are used to construct a DAG.
   Edges point to dependencies.
For metadata and avoiding unnecessarily generating jobs for already
cached derivations:
 - `isCached`, which is true if the derivation was found in a cache
   is used to exclude exactly those.
 - `attrPath`, an array of attribute names that lead from the attribute
   given as `--flake` argument to `nix-eval-jobs` to the respective
   derivation.
 - `name`, the name of the derivation, used to name jobs.

See:
 - https://jsonlines.org/
 - https://github.com/nix-community/nix-eval-jobs
 - https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs>
"""


def system_to_platform(system: str) -> list[str]:
    """
    Maps a "system" (in the Nix sense)
    to a machine type (in the GitHub Actions sense).
    See:
     - https://github.com/NixOS/nixpkgs/blob/master/lib/systems/examples.nix
     - https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idruns-on
    """
    return {
        "x86_64-linux": ["ubuntu-22.04"],
        "x86_64-darwin": ["macos-12"],
    }[system]


def main():
    if 1 != (argc := len(argv) - 1):
        print(
            f"""\
Expecting exactly one command line argument, but {argc} were given.

The argument must be the flake output attribute path that
nix-eval-jobs was invoked with. For example:
        
    nix-eval-jobs … --flake ".#checks.x86_64-linux" \\
      | {argv[0]} ".#checks.x86_64-linux"
        
This is required for reconstruction of the full flake
output attribute, since nix-eval-jobs omits the prefix.\
"""
        )
        exit(1)

    g = DiGraph()
    g.add_nodes_from(
        [
            (attr["drvPath"], attr)
            for attr in map(loads, stdin)
            if not attr.get("isCached", False)
        ]
    )
    g.add_edges_from(
        [(u, v) for u in g.nodes for v in g.nodes[u]["inputDrvs"] if v in g.nodes]
    )

    def path(v: str) -> str:
        return argv[1] + "." + ".".join(f'"{x}"' for x in g.nodes[v]["attrPath"])

    def name(v: str) -> str:
        return g.nodes[v]["name"]

    dump(
        {
            "include": [
                {
                    "attributes": list(map(path, s)),
                    "names": list(map(name, s)),
                    "platform": system_to_platform(g.nodes[s[0]]["system"]),
                }
                for s in map(
                    lambda c: list(
                        lexicographical_topological_sort(induced_subgraph(g, c))
                    ),
                    weakly_connected_components(g),
                )
            ]
        },
        stdout,
    )


if __name__ == "__main__":
    main()
