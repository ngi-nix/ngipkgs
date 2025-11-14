{#Contributor_How_to_maintain_updatability_of_a_package_with_nix-update-script}
# How to maintain updatability of a package with `nix-update-script`?

[nix-update](https://github.com/Mic92/nix-update/)
provides an integration into `passthru.updateScript`
at `pkgs.nix-update-script`:
```nix
passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
```
