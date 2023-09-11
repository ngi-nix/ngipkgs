In order to run `sudo ./ping.sh`, you need a shell with `rosenpass` and `wireguard-tools`:

``` bash
nix shell .#rosenpass nixpkgs#wireguard-tools
```
