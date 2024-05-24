# NGI Infra Documentation

## Hosts

- `makemake`

  A Hetzner physical node in Falkenstein, Germany.

## Rebuilding `makemake`

A clone of this repository is stored at `/root/ngipkgs`, and is the source of
truth for what is applied in `makemake`.

To make changes to `makemake`:
1. Create a new branch with your changes in this repository
2. Push it to GitHub
3. SSH into `makemake`:
   1. Pull your changes into `/root/ngipkgs` and switch to that branch.
   2. Apply your changes:
      ```
      nixos-rebuild switch --show-trace -L --flake /root/ngipkgs/#makemake
      ```
