# NGIPKGS

[Ngipkgs](https://github.com/ngi-nix/ngipkgs) is a collection of [Nix](https://nixos.org/) packages and services for software projects that are supported through the [Next Generation Internet](https://www.ngi.eu/) (NGI) program of the European Commission.

## Structure of Ngipkgs

The software in Ngipkgs can be divided into two broad categories: Nix packages, and NixOS services.

Nix packages can theoretically be built and run on any operating system that runs the Nix package manager. The output of building a Nix package is often a usable library or executable and most if not all of its dependencies. In Ngipkgs, these packages are all contained in the `pkgs` directory, and also listed in the file `all-packages.nix`.  

NixOS services are nix packages that are designed to be configured through, and run persistently on, the NixOS operating system. These services are configured with options defined in the `modules` directory of Ngipkgs, and they are ready to be deployed to a new NixOS host (such as a container, VM, or physical machine) using NixOS configuration templates listed in the `configs` directory.

```
.
├── all-packages.nix              # import package directories here
├── configs
│   ├── all-configurations.nix    # import configuration files here
│   └── ...                       # add configuration directories here
├── nixpkgs-candidates            # contains packages that could be upstreamed to nixpkgs
│   └── ...
├── flake.lock
├── flake.nix
├── modules
│   ├── all-modules.nix           # import module files here
│   └── ...                       # add module files here  
├── pkgs                          # add package directories here
├── README.md                     # this file
```

## Add and build a package

Packagers are encouraged to contribute NGI projects to nixpkgs, instead of to this repository.
However, reasons to contribute to this repository include:

- Package is not a good candidate for nixpkgs. [Read here](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md).
    - Place this package in the `pkgs` directory.
- Expediting the public availability of a package prior to its acceptance into nixpkgs and landing in a channel.
    - Place this package in the `nixpkgs-candidates` directory with a comment linking to the PR to nixpkgs.
- Package is a good candidate for nixpkgs, but no one is willing to be a maintainer :cry:.
    - Place this packge in the `nixpkgs-candidates` directory.

For each package there is a directory in `pkgs` or `nixpkgs-candidates` that contains a core `default.nix` file and possibly other files required to build the package. Each package directory must also be imported into Ngipkgs by adding a line to the file `all-packages.nix`. For example, this is the import line for building the libgnunetchat package:
```
libgnunetchat = callPackage ./pkgs/libgnunetchat { };
```
This package can then be built using the following command:
```
nix build .#libgnunetchat
```

## Add and test a service

For each service there is a module file in the `modules` directory which is where most of the work is done to define the configuration for a service. Whereas the default.nix for a package usually somewhat corresponds to the upstream instructions for building and installing from source, the module for a service will correspond to the instructions for configuring and running the software persistently, including integration with other system components such as a systemd service or a web server config. Each module must also be imported into Ngipkgs by adding a line to the file `modules/all-modules.nix`.

A service has its NixOS configuration options defined in its module. To actually be used, this module file must be imported into a NixOS system configuration so that the options can be used and the service deployed or tested. There is a directory in `configs` for each service that contains NixOS configuration template files for practical use of the service to different contexts. Each configuration must also be imported into Ngipkgs by adding a line to the file `configs/all-configurations.nix`. For example, these are the import lines for deployment of pretalx with postgresql:
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
More details on running pretalx in a test VM are available in the [README](https://github.com/ngi-nix/ngipkgs/edit/main/pkgs/pretalx/README.md) for this service.

[TODO: Add details about how to do more production-like deployments that require non-default config options.]

[TODO: How to import all of Ngipkgs as an input to an existing NixOS configuration, in order to deploy a service alongside other services on the same virtual or physical machine.]

## Continuous builds of packages with Hydra

Once they are merged into the main branch of the repo, all of the packages in Ngipkgs are a automatically built by a Hydra server. The results of these builds can be seen at https://hydra.ngi0.nixos.org/jobset/ngipkgs/main#tabs-jobs

## Reasoning for creation of the Ngipkgs monorepo

- The user can discover ngi projects through a unified webpage and expectation is set that many of them are research projects.
- The developers get a unified code structure, CI & CD tooling, and a common PR and issue tracker which facilitates reviews.
- The funding organizations get an easy overview of the packaging situation.
