## Add and build a package

Packagers are encouraged to contribute NGI projects to nixpkgs, instead of to this repository.
However, reasons to contribute to this repository include:

- Package is not a good candidate for nixpkgs. [Read here](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md).
    - Place this package in the `pkgs` directory.
- Expediting the public availability of a package prior to its acceptance into nixpkgs and landing in a channel.
    - Place this package in the `nixpkgs-candidates` directory with a comment linking to the PR to nixpkgs.
- Package is a good candidate for nixpkgs, but no one is willing to be a maintainer :cry:.
    - Place this packge in the `nixpkgs-candidates` directory.

For each package there is a directory in `pkgs` or `nixpkgs-candidates` that contains a core `default.nix` file and possibly other files required to build the package. Each package directory must also be imported into NGIpkgs by adding a line to the file `all-packages.nix`. For example, this is the import line for building the libgnunetchat package:
```
libgnunetchat = callPackage ./pkgs/libgnunetchat { };
```
This package can then be built using the following command:
```
nix build .#libgnunetchat
```

## Add and test a service

For each service there is a module file in the `modules` directory which is where most of the work is done to define the configuration for a service. Whereas the default.nix for a package usually somewhat corresponds to the upstream instructions for building and installing from source, the module for a service will correspond to the instructions for configuring and running the software persistently, including integration with other system components such as a systemd service or a web server config. Each module must also be imported into NGIpkgs by adding a line to the file `modules/all-modules.nix`.

A service has its NixOS configuration options defined in its module. To actually be used, this module file must be imported into a NixOS system configuration so that the options can be used and the service deployed or tested. There is a directory in `configs` for each service that contains NixOS configuration template files for practical use of the service to different contexts. Each configuration must also be imported into NGIpkgs by adding a line to the file `configs/all-configurations.nix`. For example, these are the import lines for deployment of pretalx with postgresql:
```
    pretalx-postgresql = {
    imports = [
      ./pretalx/pretalx.nix
      ./pretalx/postgresql.nix
    ];
```
This service can then be deployed on NixOS to a local VM running integration tests using the following comamands:
```sh
nix build -L .#nixosTests.x86_64-linux.pretalx.driverInteractive
./result/bin/nixos-test-driver # Start a shell
```

Once in the spawned shell, you can start a VM that will execute the tests using the following command:
```python
start_all() # Run the VM
```
More details on running pretalx in a test VM are available in the [README](https://github.com/ngi-nix/NGIpkgs/edit/main/pkgs/pretalx/README.md) for this service.

<!-- TODO: Add details about how to do more production-like deployments that require non-default config options. -->

<!-- TODO: How to import all of NGIpkgs as an input to an existing NixOS configuration, in order to deploy a service alongside other services on the same virtual or physical machine. -->
