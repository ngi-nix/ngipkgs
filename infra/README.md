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

## Using `makemake` as a remote build machine

If you're a participant of [Summer of Nix](https://github.com/ngi-nix/summer-of-nix), you can use `makemake` as a [remote build](https://nix.dev/manual/nix/stable/advanced-topics/distributed-builds) host.
To get access to `makemake`, open a Pull Request where you add your public SSH key to the `remotebuild` list in `ssh-keys.nix`.
Once your change is merged and deployed, you can verify you can access the remote store with `nix store ping --store ssh-ng://remotebuild@makemake.ngi.nixos.org`.
For more information on remote builds, please consult the [nix documentation](https://nix.dev/manual/nix/stable/advanced-topics/distributed-builds).
