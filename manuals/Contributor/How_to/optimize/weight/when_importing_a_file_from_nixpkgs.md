{#Contributor_How_to_optimize_weight_when_importing_a_file_from_nixpkgs}
# How to optimize weight when importing a file from nixpkgs?

Use `pkgs.path + "/path/to/file.nix"`,
which reuses the `pkgs.path` already in the Nix store,
instead of `"${pkgs.path}/path/to/file.nix"`,
which copies `pkgs.path` into the Nix store again.

```console
$ nix -L eval --impure --expr 'with (import ./default.nix {}); pkgs.path + "/pkgs/by-name/de/devmode/package.nix"'
"/nix/store/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-source/pkgs/by-name/de/devmode/package.nix"
```

```console
$ nix -L eval --impure --expr 'with (import ./default.nix {}); "${pkgs.path}/pkgs/by-name/de/devmode/package.nix"'
"/nix/store/yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-source/pkgs/by-name/de/devmode/package.nix"
```

As a special case when importing a file from `nixpkgs`'s `nixos/modules/`,
one can use `modulesPath`:
```nix
{ pkgs, lib, config, modulesPath, ... }:
{
  options.services.ngi-pretalx = {
    nginx = lib.mkOption {
      type = lib.types.submodule (
        import (modulesPath + "/services/web-servers/nginx/vhost-options.nix") {
          inherit config lib;
        }
      );
    };
  };
}
```
