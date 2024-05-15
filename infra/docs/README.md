# NGI Infra Documentation

## Hosts / Inventory

We currently have a single host that's part of the NGI infrastructure. The host
is called `makemake` and is a Hetzner physical node in Falkenstein, Germany.

## Rebuilding `makemake`
Under `/root/ngipkgs` a cloned version of this repository exists that is the
source of truth for what is applied in `makemake`. In order to make changes to
`makemake`, create a new branch with your changes in this repository, push it to
github, pull your changes into `/root/ngipkgs` and switch to that branch. Then
apply your changes with:

```
nixos-rebuild switch --show-trace -L --flake /root/ngipkgs/#makemake
```