# NGIPKGS

## Reasoning

- The user can discover ngi projects through a unified webpage and expectation is set that many of them are research projects.
- The developers get a unified code structure, CI & CD tooling, and a common PR and issue tracker which facilitates reviews.
- The funding organizations get an easy overview of the packaging situation.

```
.
├── all-packages.nix              # 
├── configs
│   ├── all-configurations.nix    # import configuration files here
│   └── ...                       # add configuration files here
├── configuration.nix
├── default.nix
├── flake.lock
├── flake.nix
├── modules
│   ├── all-modules.nix             # import module files here
│   └── ...
├── pkgs                            # add packages here
├── README.md                       # this file
```
