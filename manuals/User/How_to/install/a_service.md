{#User_How_to_install_a_service}
# How to install a service?

When using a `flake.nix` you can import from NGIpkgs' `nixosModules.services` like this:
```{literalinclude} a_service/flake.nix
:language: nix
:caption: flake.nix
```

This provision new options in your NixOS configuration,
starting with `services.${service}.enable`
which when enabled configures the service `${service}`
in at least a minimal usable configuration.

If other services are absolutely required on the same host
for `${service}` to work properly,
they are automatically enabled as well.

Besides, convenient opt-in options may also be available as well
to enable an integration into other required services running on the same host.
For example, `services.${service}.nginx.enable`
may be available to setup an Nginx reverse proxy.

<!-- ToDo: refer to a section of the manual listing all available options. -->
