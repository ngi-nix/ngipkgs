{#User_How_to_install_Nix}
# How to install Nix?

Nix-the-language has multiple implementations:

- [CppNix](https://nixos.org/download/) is the original implementation that is the most widely used.
  This is the main implementation supported by NGIpkgs.
  If in doubt install this.

- [Lix](https://docs.lix.systems/manual/lix/stable/installation/supported-platforms.html)
  is an alternative implementation that maintain some level of compatibility with `CppNix`,
  and thus may work well on NGIpkgs.

- [Tvix](https://tvix.dev/)
  is alternative implementation that is not (yet) supported by NGIpkgs.
