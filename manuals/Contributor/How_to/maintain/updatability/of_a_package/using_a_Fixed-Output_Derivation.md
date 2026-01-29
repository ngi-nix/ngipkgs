{#Contributor_How_to_maintain_updatability_of_a_package_using_a_Fixed-Output_Derivation}
# How maintain updatability of a package using a Fixed-Output Derivation?

With [nurl](https://github.com/nix-community/nurl):
> Generate Nix fetcher calls from repository URLs

For example, this updates `bonfire.mixNixDeps.${name}.yarnOfflineCache`:
```bash
nurl --expr '(import ./. {}).bonfire.mixNixDeps.${name}.yarnOfflineCache' \
  >pkgs/by-name/bonfire/deps/${name}/yarnOfflineCache.hash
```

Recording the hash in a file makes the update easier to write and track,
but instead of an inline `hash`, it requires the derivation to use something like:
```nix
hash = lib.readFile ./yarnOfflineCache.hash;
```

:::{warning}
Beware that a Fixed-Output Derivation (FOD)
is not rebuilt when any of its inputs change
but [when its output `hash` or its `name` changes](https://blog.eigenvalue.net/nix-rerunning-fixed-output-derivations/).

This cache invalidation can be subtly hard,
for instance when using `pkgs.fetch*` it [usually means that at least `version`
must be leaked into the `name`](#Contributor_Why_to_maintain_updatability_of_a_package_using_a_Fixed-Output_Derivation_by_leaking_version_into_name):
```bash
pkgs.fetchFromGitHub {
  name = "opencv_contrib-${version}";
  owner = "opencv";
  repo = "opencv_contrib";
  tag = version;
  hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M=";
};
```
otherwise bumping `version` [will not spot the mismatching `hash`](https://github.com/NixOS/nixpkgs/pull/459592)
when building on a Nix store already having the previous `version` in cache.
:::
