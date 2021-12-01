# About this flake

This Nix flake packages [Weblate](https://weblate.org/en/), a web based translation tool.

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

The goal of this flake is eventually to be integrated into Nixpkgs. Write me a message if you are interested in helping with this!

One problem I already anticipate is that the `poetry.lock` (weighing about 100k currently) will be considered too large for a relative unknown packages. But I'm willing to try it eventually.
