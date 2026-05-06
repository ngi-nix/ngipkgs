{#User_How_to_install_NGIpkgs_using_a_flake_nix}
# How to install NGIpkgs using a `flake.nix`?

You can insert this input in your `flake.nix`:
```nix
inputs.NGIpkgs.url = "github:ngi-nix/ngipkgs";
```

To avoid building dependencies of NGIpkgs' packages and services,
you may ask users of your `flake.nix` to enable NGIpkgs' public build cache,
by inserting this in your `flake.nix`:
```nix
nixConfig = {
  extra-substituters = [ "https://ngi.cachix.org" ];
  extra-trusted-public-keys = [ "ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw=" ];
```

If you want to accept such configuration from `flake.nix` automatically,
you can add this setting in your NixOS configuration:
```nix
nix.settings.accept-flake-config = true;
```

If, when prompted, you trusted permanently that `nixConfig`,
you can still revert your trust by editing a file usually
located at `~/.local/share/nix/trusted-settings.json`.
