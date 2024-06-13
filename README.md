# NGIpkgs

[Nix] packages, [NixOS] modules and example NixOS configurations of software projects funded by the [Next Generation Internet] (NGI) initiative of the European Commission.

[Nix]: https://nixos.org/manual/nix
[NixOS]: https://nixos.org/manual/nixos
[Next Generation Internet]: https://www.ngi.eu

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
