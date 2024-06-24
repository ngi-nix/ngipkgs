# About this flake

This Nix flake packages [Weblate](https://weblate.org/en/), a web based translation tool. It is fully usable and tested regularly.

# Usage

The primary use of this flake is deploying Weblate on NixOS. For that you would use the NixOS module available in `.#nixosModule`.

If you have that module available in your NixOS config, configuration is straightforward. See e.g. this example config:

```nix
{ config, lib, pkgs, ... }: {

  services.weblate = {
    enable = true;
    localDomain = "weblate.example.org";
    # E.g. use `base64 /dev/urandom | head -c50` to generate one.
    djangoSecretKeyFile = "/path/to/secret";
    smtp = {
      createLocally = true;
      user = "weblate@example.org";
      passwordFile = "/path/to/secret";
    };
  };

}
```


# Putting Weblate into Nixpkgs

Originally the goal of this flake was to [package Weblate in Nixpkgs](https://github.com/NixOS/nixpkgs/pull/169797), but as [support for Poetry2nix was dropped in Nixpkgs](https://github.com/NixOS/nixpkgs/pull/263308), that is no longer feasible.

AFAIR there is no current effort to make Weblate available in Nixpkgs directly, even though it would be possible to achieve without using Poetry2nix.

