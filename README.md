*Unfortunately I currently have some trouble upgrading to the latest Weblate version (4.16.4 as the time of writing). If you want to help with the build errors, have a look at my current progress in the [`dev` branch](https://github.com/ngi-nix/weblate/tree/dev).*

# About this flake

This Nix flake packages [Weblate](https://weblate.org/en/), a web based translation tool. It is fully usable and tested regularly.

# Putting Weblate into Nixpkgs

Currently I try to get this package module [to be merged into Nixpkgs](https://github.com/NixOS/nixpkgs/pull/169797). If you want to help, please leave a review there! If the module gets merged, this repository will be archived.

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


