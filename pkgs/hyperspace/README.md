# hyperspace

This repository is a monorepo which holds various tools and packages related to the [Hypercore protocol](https://hypercore-protocol.org). These packages are built via [dream2nix](https://github.com/nix-community/dream2nix).

You can list the available packages by running:
```
nix flake show github:ngi-nix/hyperspace
```
For example to run `hyperbeam` all you have to do is run the following command:
```
nix run github:ngi-nix/hyperspace#hyperbeam
```
