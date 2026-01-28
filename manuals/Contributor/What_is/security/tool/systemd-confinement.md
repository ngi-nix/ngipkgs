{#Contributor_What_is_security_tool_systemd-confinement}
# What is security tool `systemd-confinement`?

[`systemd-confinemenŧ`](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/security/systemd-confinement.nix)
is specific to NixOS,
it leverages `pkgs.closureInfo` to only bind necessary Nix store paths
within the `RootDirectory=` of the systemd service.

It is compatible with `DynamicUser=true` add `ProtectSystem=strict`.
