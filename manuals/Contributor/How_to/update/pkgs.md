{#Contributor_How_to_update_pkgs}
# How to update `pkgs`?

To update a package `pkgs.${package}`:
1. Try to run any provided update script with:
```bash
nix develop -f . shell -c update ${package}
```
Alternatively, with something much faster to warmup
because it's not neither `nix-update`
nor `flake.nix` which copies everything into the Nix store:
```console
nix -L develop --impure --expr 'import <nixpkgs/maintainers/scripts/update.nix> {
  include-overlays = [ (final: prev: { inherit (import ./. {}) ngipkgs; }) ];
  package = "ngipkgs.${package}"; }'
```

2. Review that all the fixed-output derivation hashes
have indeed been updated.

3. Fix any problems until `${package}` builds successfully:
```bash
nix -L build -f . ${package}
```

```{toctree}
pkgs/bonfire.md
```
