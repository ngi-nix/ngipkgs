# NGIpkgs

[Nix] is an open source build system, configuration management system, and mechanism for deploying software, focused on reproducibility.
It is the basis of an ecosystem of exceptionally powerful tools.
Nixpkgs is [the largest, most up-to-date software repository in the world][repology].
NixOS is a Linux distribution that can be configured fully declaratively, with unmatched flexibility.

Many software projects funded by the [Next Generation Internet] (NGI) initiative of the European Commission through the [NLnet Foundation] are not mature enough to distribute through Nixpkgs, or cannot be included in Nixpkgs for technical reasons.
This repository makes such projects available as

- Package recipes compatible with [Nixpkgs]
- Configuration modules compatible with [NixOS]

and provides automatically tested example NixOS configurations.

NGIpkgs was created as part of [Summer of Nix], organised by the [NixOS Foundation].

[Nix]: https://github.com/NixOS/nix
[repology]: https://repology.org/repositories/graphs
[Nixpkgs]: https://github.com/nixos/nixpkgs
[NixOS]: https://nixos.org/manual/nixos
[Next Generation Internet]: https://www.ngi.eu
[NLnet Foundation]: https://nlnet.nl
[Summer of Nix]: https://github.com/ngi-nix/summer-of-nix
[NixOS Foundation]: https://nixos.org/community/#foundation

# How to use software from NGIpkgs

This is what you can do with software from NGIpkgs:
- Run **standalone programs** locally with Nix
- Use **libraries or tools** to build software with Nixpkgs
- Deploy **services** to machines running NixOS

In order to do that:
- [Install Nix on Linux or WSL](https://nix.dev/install-nix)
- [Enable the flakes experimental feature](https://wiki.nixos.org/wiki/Flakes)

It will help you to go more quickly if you learn to:
- [Read the Nix language](https://nix.dev/tutorials/nix-language)
- [Package existing software with Nixpkgs](https://nix.dev/tutorials/packaging-existing-software)
- [Work with NixOS modules](https://nix.dev/tutorials/module-system/)
- [Run NixOS in virtual machines](https://nix.dev/tutorials/nixos/nixos-configuration-on-vm)

## Structure of NGIpkgs

The software in NGIpkgs can be divided into two broad categories: Nix packages, and NixOS modules.

```
.
├── flake.nix
├── pkgs
│   └── by-name
│       └── …            # directories of packages
├── projects
│   ├── <project-name>   # names matching those at https://nlnet.nl/project
│   │   ├── default.nix  # project definition
│   │   └── …            # files of the project (e.g. NixOS module, configuration, tests, etc.)
│   └── default.nix      # imports all projects 
├── README.md            # this file
└── …
```

Nix packages can theoretically be built and run on any operating system that runs Nix.
The output of building a Nix package is often a library or executable, including its dependencies.
In NGIpkgs, these packages are all contained in [the `pkgs` directory](./pkgs).
For simple package definitions, we use `pkgs/by-name/<pname>/package.nix`, inspired by [Nix RFC 140].

[Nix RFC 140]: https://github.com/NixOS/rfcs/blob/c8569f6719356009204133cd00d92010889ed56d/rfcs/0140-simple-package-paths.md

Corresponding to [projects funded by NGI through NLnet](https://nlnet.nl/project/) there are per-project subdirectories within [the `projects` directory](./projects).
These per-project directories contain a `default.nix` which
- Picks packages associated with the project from those defined in `pkgs` and Nixpkgs,
- Exposes NixOS modules, tests, and configurations which are also contained in the per-project directory,
- May contain additional metadata about the project.

NixOS modules are components that can be easily integrated into a NixOS configuration.
Many of them represent services that map to one or more systemd services that are designed to run on NixOS.
These modules are ready to be deployed to a NixOS system, such as a container, virtual machine, or physical machine.
Example configurations found in the corresponding per-project directory are a good starting point for anyone interested in using these modules, and are sure to work because they are also used for testing.

## How to install software from NGIpkgs

Installation of software from NGIpkgs currently requires Nix [flakes to be enabled](https://nixos.wiki/wiki/Flakes).

### Install to a local VM with QEMU

For more information on how to deploy software from NGIpkgs to a local VM with QEMU, see this example repository: https://github.com/ngi-nix/flakes-ngipkgs

### Install to an existing NixOS flake

Here is a minimal `flake.nix` that installs the default module from NGIpkgs, containing all the of the packages from the repo:
```
{
  inputs.ngipkgs.url = "github:ngi-nix/ngipkgs";
  # Optional:
  # inputs.ngipkgs.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, agenix }: {
    # Change `yourhostname` to your actual hostname
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      # change to your system:
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ngipkgs.nixosModules.default
      ];
    };
  };
}
```

Now any NGIpkgs package can be installed in the `configuration.nix` in the same ways as any package from nixpkgs.

Each project within NGIpkgs has its own module that must also be added in order to deploy the services for that project.
To use the Vula project as an example:
```
        modules = [
          configuration.nix
          ngipkgs.nixosModules.default
          ngipkgs.nixosModules."services.vula"
```

The Vula service can then be enabled in the `configuration.nix`, as documented in the [`example-simple.nix`](https://github.com/ngi-nix/ngipkgs/blob/main/projects/Vula/example-simple.nix) for the project:
```
  services.vula.enable = true;
  services.vula.openFirewall = true;
```

The list of projects that are available to be deployed in this way, and how the module for each one is labelled, is available in the `nixosModules` section of the outputs listed by the `nix flake show` command when run in the NGIpkgs repo.

## Continuous builds of packages with Hydra

All packages in the [main branch of NGIpkgs](https://github.com/ngi-nix/ngipkgs/tree/main) are automatically built by a [Hydra](https://github.com/NixOS/hydra) server.
The results of these builds can be found at <https://hydra.ngi0.nixos.org/jobset/ngipkgs/main#tabs-jobs>

## Reasoning for creation of the NGIpkgs monorepo

- Users can discover NGI projects on an [overview page](https://ngi-nix.github.io/ngipkgs/) and use them immediately.
- Many software packages are research projects that would not make sense to distribute through Nixpkgs.
- The developers get a unified code structure, CI & CD tooling, and a common pull request and issue tracker which facilitates reviews.
- The funding organizations get an overview of the packaging situation.

## Contributing to NGIpkgs

Please see [`CONTRIBUTING.md`](CONTRIBUTING.md)
