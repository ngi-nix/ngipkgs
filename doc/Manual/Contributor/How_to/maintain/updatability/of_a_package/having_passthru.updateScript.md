# How to maintain updatability of a package having a `passthru.updateScript` {#Contributor_How_to_maintain_updatability_of_a_package_having_a_passthru.updateScript}

A [`passthru.updateScript`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#automatic-package-updates)
is the conventional way to provide a script to update a package.

In NGIpkgs updating a package named `packageNameToUpdate` can be done like so:
```bash
nix -L develop
update $packageNameToUpdate
```

Alternatively, with something a bit faster to warmup because it's not using `nix-update`:
```nix
nix -L develop --impure --expr 'import <nixpkgs/maintainers/scripts/update.nix> { \
  include-overlays = [ (final: prev: { inherit (import ./. {}) ngipkgs; }) ]; \
  package = "ngipkgs.packageNameToUpdate"; }'
```
