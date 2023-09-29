# NGIpkgs

[NGIpkgs](https://github.com/ngi-nix/NGIpkgs) is a collection of [Nix](https://nixos.org/) packages and services for software projects that are supported through the [Next Generation Internet](https://www.ngi.eu/) (NGI) initiative of the European Commission.

## Packages

|Name                                                            |Website                                     |Version |Description                                                                                                                               |License   |
|----------------------------------------------------------------|--------------------------------------------|--------|------------------------------------------------------------------------------------------------------------------------------------------|----------|
|[`atomic-cli`](/pkgs/atomic-cli/default.nix)                    |[link](https://crates.io/crates/atomic-cli) |0.34.5  |CLI tool to create, store, query, validate and convert Atomic Data                                                                        |MIT       |
|[`atomic-server`](/pkgs/atomic-server/default.nix)              |[link](docs.atomicdata.dev)                 |0.34.5  |A Rust library to serialize, parse, store, convert, validate, edit, fetch and store Atomic Data. Powers both atomic-cli and atomic-server.|MIT       |
|[`flarum`](/pkgs/flarum/default.nix)                            |[link](https://github.com/flarum/flarum)    |1.8.0   |Flarum is a delightfully simple discussion platform for your website                                                                      |MIT       |
|[`gnunet-messenger-cli`](/pkgs/gnunet-messenger-cli/default.nix)|                                            |0.1.1   |                                                                                                                                          |          |
|[`kikit`](/pkgs/kikit/default.nix)                              |[link](https://github.com/yaqwsx/KiKit/)    |1.3.0   |Automation for KiCAD boards                                                                                                               |MIT       |
|[`lcrq`](/pkgs/lcrq/default.nix)                                |[link](https://librecast.net/lcrq.html)     |0.1.0   |Librecast RaptorQ library.                                                                                                                |...       |
|[`lcsync`](/pkgs/lcsync/default.nix)                            |[link](https://librecast.net/lcsync.html)   |0.2.1   |Librecast File and Syncing Tool                                                                                                           |...       |
|[`libgnunetchat`](/pkgs/libgnunetchat/default.nix)              |                                            |0.1.3   |                                                                                                                                          |          |
|[`librecast`](/pkgs/librecast/default.nix)                      |[link](https://librecast.net/librecast.html)|0.7-RC3 |IPv6 multicast library                                                                                                                    |...       |
|[`pretalx`](/pkgs/pretalx/default.nix)                          |[link](https://github.com/pretalx/pretalx)  |2023.1.3|Conference planning tool: CfP, scheduling, speaker management                                                                             |Apache-2.0|
|[`pretalx-downstream`](/pkgs/pretalx/plugins.nix)               |                                            |1.1.5   |                                                                                                                                          |          |
|[`pretalx-frontend`](/pkgs/pretalx/frontend.nix)                |[link](https://github.com/pretalx/pretalx)  |2023.1.0|Conference planning tool: CfP, scheduling, speaker management                                                                             |Apache-2.0|
|[`pretalx-full`](/pkgs/pretalx/default.nix)                     |[link](https://github.com/pretalx/pretalx)  |2023.1.3|Conference planning tool: CfP, scheduling, speaker management                                                                             |Apache-2.0|
|[`pretalx-media-ccc-de`](/pkgs/pretalx/plugins.nix)             |                                            |1.1.1   |                                                                                                                                          |          |
|[`pretalx-pages`](/pkgs/pretalx/plugins.nix)                    |                                            |1.3.3   |                                                                                                                                          |          |
|[`pretalx-public-voting`](/pkgs/pretalx/plugins.nix)            |                                            |1.3.0   |                                                                                                                                          |          |
|[`pretalx-venueless`](/pkgs/pretalx/plugins.nix)                |                                            |1.3.0   |                                                                                                                                          |          |
|[`rosenpass`](/pkgs/rosenpass/default.nix)                      |[link](https://rosenpass.eu/)               |0.2.0   |Build post-quantum-secure VPNs with WireGuard!                                                                                            |...       |
|[`rosenpass-tools`](/pkgs/rosenpass-tools/default.nix)          |[link](https://rosenpass.eu/)               |0.2.0   |Build post-quantum-secure VPNs with WireGuard! This package contains `rp`, which is a script that wraps the `rosenpass` binary.           |...       |

## Structure of NGIpkgs

The software in NGIpkgs can be divided into two broad categories: Nix packages, and NixOS modules.

Nix packages can theoretically be built and run on any operating system that runs the Nix package manager. The output of building a Nix package is often a usable library or executable and most if not all of its dependencies. In NGIpkgs, these packages are all contained in the `pkgs` directory. For simple package definitions, we use `pkgs/by-name/<pname>/package.nix`, inspired by [Nix RFC 140](https://github.com/NixOS/rfcs/blob/c8569f6719356009204133cd00d92010889ed56d/rfcs/0140-simple-package-paths.md). Otherwise, packages are added in `pkgs/<pname>/default.nix` imported in `pkgs/default.nix`.  

NixOS modules are components that can be easily integrated into NixOS. Usually they enrich Nix packages with configuration parameters. Many of them represent services that map to one or more systemd service(s) that are designed to, run persistently on NixOS. These modules are defined in the `modules` directory of NGIpkgs, and they are ready to be deployed to a new NixOS system (such as a container, VM, or physical machine). Templates in `configs` are a good starting point for anyone interested in using modules, and they are also used for testing.

```
.
├── flake.nix
├── pkgs
│   ├── by-name
│   │   └── ...           # directories of packages that are added `by-name`
│   ├── default.nix       # imports all packages that are not in `by-name`
│   └── ...               # directories for packages
├── modules
│   └── ...                       # add module files here  
├── README.md                     # this file
├── configs
│   ├── all-configurations.nix    # import configuration files here
│   └── ...                       # add configuration directories here
└── ...
```

## Continuous Builds of Packages with Hydra

All packages in the main branch of NGIpkgs are automatically built by a [Hydra](https://github.com/NixOS/hydra) server. The results of these builds can be seen at <https://hydra.ngi0.nixos.org/jobset/NGIpkgs/main#tabs-jobs>

## Reasoning for Creation of the NGIpkgs Monorepo

- The user can discover NGI projects through a unified webpage and expectation is set that many of them are research projects.
- The developers get a unified code structure, CI & CD tooling, and a common PR and issue tracker which facilitates reviews.
- The funding organizations get an easy overview of the packaging situation.

## Contributing to NGIpkgs

Please see [`CONTRIBUTING.md`](CONTRIBUTING.md)
