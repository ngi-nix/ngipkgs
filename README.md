# NGIpkgs

[Nix] packages, [NixOS] modules and example NixOS configurations
of software projects funded by
the [Next Generation Internet][NGI] (NGI) initiative of the European Commission

## Structure of NGIpkgs

The software in NGIpkgs can be divided into two broad categories: Nix packages, and NixOS modules.

Nix packages can theoretically be built and run on any operating system that runs the Nix package manager.
The output of building a Nix package is often a usable library or executable and most if not all of its dependencies.
In NGIpkgs, these packages are all contained in the `pkgs` directory.
For simple package definitions, we use `pkgs/by-name/<pname>/package.nix`, inspired by [Nix RFC 140][rfc-140].
Otherwise, packages are added in `pkgs/<pname>/default.nix` imported in `pkgs/default.nix`.

Corresponding to [funded projects](https://nlnet.nl/project/) there are per-project subdirectories within the `projects` directory.
These per-project directories contain a `default.nix` which
(a) picks packages associated with the project from those defined in `pkgs` and Nixpkgs,
(b) exposes NixOS modules, tests and configurations which are also contained in the per-project directory,
(c) may contain additional metadata about the project.

NixOS modules are components that can be easily integrated into NixOS.
Usually they enrich Nix packages with configuration parameters.
Many of them represent services that map to one or more systemd service(s) that are designed to, run persistently on NixOS.
These modules are ready to be deployed to a new NixOS system (such as a container, VM, or physical machine).
Templates configurations found in the corresponding per-project directory are a good starting point for anyone interested in using modules, and they are also used for testing.

```
.
├── flake.nix
├── pkgs
│   ├── by-name
│   │   └── …            # directories of packages that are added `by-name`
│   ├── default.nix      # imports all packages that are not in `by-name`
│   └── …                # directories for packages
├── projects
│   ├── <project-name>   # names match with those at https://nlnet.nl/project
│   │   ├── default.nix  # project definition
│   │   └── …            # files of the project (e.g. NixOS module, configuration, tests, etc.)
│   └── …
├── README.md            # this file
└── …
```

## Continuous Builds of Packages with Hydra

All packages in the main branch of NGIpkgs are automatically built by a [Hydra](https://github.com/NixOS/hydra) server.
The results of these builds can be seen at <https://hydra.ngi0.nixos.org/jobset/NGIpkgs/main#tabs-jobs>

## Reasoning for Creation of the NGIpkgs Monorepo

- The user can discover NGI projects through a unified webpage and expectation is set that many of them are research projects.
- The developers get a unified code structure, CI & CD tooling, and a common PR and issue tracker which facilitates reviews.
- The funding organizations get an easy overview of the packaging situation.

## Contributing to NGIpkgs

Please see [`CONTRIBUTING.md`](CONTRIBUTING.md)

[Nix]: https://nixos.org/manual/nix
[NixOS]: https://nixos.org/manual/nixos
[NGI]: https://www.ngi.eu
[rfc-140]: https://github.com/NixOS/rfcs/blob/c8569f6719356009204133cd00d92010889ed56d/rfcs/0140-simple-package-paths.md