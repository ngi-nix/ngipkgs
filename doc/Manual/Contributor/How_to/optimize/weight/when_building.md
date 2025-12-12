# How to optimize weight when building {#Contributor_How_to_optimize_weight_when_building}

Using `default.nix` with `nix -L build -f . $package`
instead of `flake.nix` with `nix -L build .#package`
does not copy NGIpkgs into the Nix store each time one builds.
