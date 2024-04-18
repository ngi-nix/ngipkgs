from fileinput import input
from json import dumps, loads
from networkx import DiGraph, induced_subgraph, lexicographical_topological_sort, weakly_connected_components

def systemToPlatform(system):
  return {
      "x86_64-linux": ["ubuntu-22.04"],
      "x86_64-darwin": ["macos-12"],
  }[system]

G = DiGraph()
for line in input():
  attr = loads(line)
  if not attr['isCached']:
    G.add_node(attr['drvPath'], **attr)

for u in G.nodes:
  for v in G.nodes[u]['inputDrvs']:
    if v in G.nodes:
      G.add_edge(u, v)

result = {'include': []}
for nodes in weakly_connected_components(G):
  g = list(lexicographical_topological_sort(induced_subgraph(G, nodes)))
  result['include'].append({
      'attributes':
      [".#checks." + ".".join("\"" + x + "\"" for x in G.nodes[x]['attrPath']) for x in g],
      'name':
      ", ".join([(G.nodes[x])['name'] for x in g]),
      'platform':
      systemToPlatform(G.nodes[g[0]]['system'])
  })

print(dumps(result))
