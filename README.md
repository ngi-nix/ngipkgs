# NGIpkgs

[Nix] is an open source build system, configuration management system, and mechanism for deploying software, focused on reproducibility.
It is the basis of an ecosystem of exceptionally powerful tools.
Nixpkgs is [the largest, most up-to-date software repository in the world][repology].
NixOS is a Linux distribution that can be configured fully declaratively, with unmatched flexibility.

This repository makes software projects which are funded by the [Next Generation Internet] (NGI) initiative of the European Commission through the [NLnet Foundation] available as

- Configuration modules compatible with [NixOS]
- Package recipes compatible with [Nixpkgs]

and provides automatically tested example NixOS configurations.

> [!TIP]
> View NGI software packaged for NixOS on <https://ngi.nixos.org>.

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

## Quick start

Add NGIpkgs as a flake input to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ngipkgs.url = "github:ngi-nix/ngipkgs";
  };

  outputs = { nixpkgs, ngipkgs, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Add NGIpkgs overlay so packages are available in pkgs.ngipkgs
        ngipkgs.nixosModules.ngipkgs

        # Import an NGIpkgs program module (e.g. formulas — a CLI tool)
        ngipkgs.nixosModules.programs.formulas

        # Import an NGIpkgs service module (e.g. funkwhale — a federated audio platform)
        ngipkgs.nixosModules.services.funkwhale

        ./configuration.nix
      ];
    };
  };
}
```

### Using packages

Packages are available under `ngipkgs.packages.<system>.<name>`.

Run a CLI tool without installing it:

```ShellSession
nix run github:ngi-nix/ngipkgs#formulas -- --help
```

Build a package locally:

```ShellSession
nix build github:ngi-nix/ngipkgs#formulas
```

Add packages to your NixOS configuration:

```nix
{ pkgs, ngipkgs, ... }: {
  environment.systemPackages = with ngipkgs.packages.${pkgs.system}; [
    formulas
    py3dtiles
  ];
}
```

Or use the NGIpkgs overlay to make packages available under `pkgs.ngipkgs`:

```nix
{ pkgs, ... }: {
  environment.systemPackages = with pkgs.ngipkgs; [
    formulas
    py3dtiles
  ];
}
```

### Using NixOS modules

NGIpkgs provides NixOS modules for both **programs** (CLI tools) and **services** (long-running daemons).

Add a module to your configuration:

```nix
{ ... }: {
  imports = [
    # Program modules make a CLI tool available on the system
    inputs.ngipkgs.nixosModules.programs.formulas

    # Service modules configure and run a background service
    inputs.ngipkgs.nixosModules.services.funkwhale
  ];

  # Enable a program
  programs.formulas.enable = true;

  # Configure a service
  services.funkwhale = {
    enable = true;
    configureNginx = true;
    settings = {
      FUNKWHALE_HOSTNAME = "music.example.com";
    };
  };
}
```

> [!TIP]
> Browse available modules at <https://ngi.nixos.org> or under `projects/` in the repository.

### Trying demos

Each project may include a demo configuration that you can run in a virtual machine:

```ShellSession
nix run github:ngi-nix/ngipkgs#demos.formulas
```

This boots a NixOS VM with the application pre-installed and configured.

### Using the NGIpkgs overlay

If you prefer to use the NGIpkgs packages as an overlay on your Nixpkgs package set:

```nix
{ pkgs, ngipkgs, ... }: {
  nixpkgs.overlays = [ ngipkgs.overlays.default ];
}
```

After adding the overlay, packages are available directly as `pkgs.formulas`, `pkgs.py3dtiles`, etc.

### Prerequisites

It will help you to go more quickly if you learn to:
- [Read the Nix language](https://nix.dev/tutorials/nix-language)
- [Package existing software with Nixpkgs](https://nix.dev/tutorials/packaging-existing-software)
- [Work with NixOS modules](https://nix.dev/tutorials/module-system/)
- [Run NixOS in virtual machines](https://nix.dev/tutorials/nixos/nixos-configuration-on-vm)
- [Provision remote NixOS machines via SSH](https://nix.dev/tutorials/nixos/provisioning-remote-machines)
- [Set up your own cache for sharing binaries](https://nix.dev/tutorials/nixos/binary-cache-setup)

## Structure of NGIpkgs

Each piece of software in NGIpkgs is called a *project*.
Each project may consist of multiple packaging artefacts:
- NixOS configuration modules for adding application components to a NixOS system
- Examples for configuring these modules
- Tests to ensure the modules and examples work as intended
- Libraries for various programming languages that can be composed with Nixpkgs package recipes
- Links to upstream documentation for using the application or maintaining or extending the NixOS packaging

```
.
├── README.md            # this file
├── default.nix          # collection of project configuration modules (and some helper tooling)
├── projects
│   ├── default.nix      # aggregates all projects
│   ├── models.nix       # data model for packaging artefacts
│   ├── <project-name>
│   │   ├── default.nix  # packaging artefacts for a project
│   …   └── …            # other files for implementing a project package
├── pkgs
│   └── by-name
│       └── …            # directories with Nixpkgs-compatible package recipes
├── flake.nix            # CI setup
└── …
```

NixOS modules can be integrated into a NixOS configuration.
Many of them expose options for configuring one or more [systemd](https://systemd.io) services that are designed to run on NixOS.
These modules are ready to be deployed to a NixOS system running in a container, virtual machine, or on a physical machine.

Example configurations found in the corresponding per-project directory are a good starting point for anyone interested in using these modules, and can be expected to work because they are automatically tested in continuous integration.

Nixpkgs-style package recipes can in principle be built on any operating system supported by Nix.
The output of building such a recipe is often a library or executable, including its dependencies.
In NGIpkgs, these recipes are maintained in [the `pkgs` directory](./pkgs).

Corresponding to [projects funded by NGI through NLnet](https://nlnet.nl/project/) there are per-project subdirectories within [the `projects` directory](./projects).
Each of these sub-directories contain a `default.nix` which
- Picks packages associated with the project from those defined in [`pkgs`](./pkgs) and [Nixpkgs],
- Exposes NixOS modules, tests, and configurations which are also maintained in the per-project directory,
- May contain additional metadata about the project
- Follows [the data model for packaging artefacts](./projects/models.nix)

## Continuous builds of packages with Buildbot

All packages in the [main branch of NGIpkgs](https://github.com/ngi-nix/ngipkgs/tree/main) are automatically built by a [Buildbot](https://github.com/buildbot/buildbot) server.
The results of these builds can be found at <https://buildbot.ngi.nixos.org/#/projects/1>

## Reasoning for creation of the NGIpkgs monorepo

- Users can discover NGI projects on an [overview page](https://ngi.nixos.org) and use them immediately.
- Many software packages are research projects that would not (yet) make sense to distribute through Nixpkgs or NixOS.
- The funding organisations get an overview of the packaging situation.
- Maintainers of the NGI software collection can experiment with code architecture and user experience without interfering with upstream NixOS development or having to deal with stricter stability requirements.

Our intention is to eventually bring innovations to Nixpkgs and NixOS once they are proven to work well and there is a realistic migration path that won't break upstream contributors' and users' workflows.

## Contributing to NGIpkgs

Please see [`CONTRIBUTING.md`](./CONTRIBUTING.md)

## Acknowledgements

NGIpkgs is funded by the European Commission's [Next Generation Internet (NGI)](https://www.ngi.eu/) initiative through the [NLNet Foundation](https://nlnet.nl/) and the [NixOS Foundation](https://github.com/NixOS/foundation).

[<img src="https://nlnet.nl/image/logos/EC.svg" alt="European Commission logo" style="width:10rem;" />](https://ngi.eu/about/)
&nbsp;&nbsp;
[<img src="https://nlnet.nl/logo/banner.svg" alt="NLnet foundation logo" style="width:10rem;" />](https://nlnet.nl/foundation/)
