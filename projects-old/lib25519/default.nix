{ pkgs, ... }@args:
{
  packages = { inherit (pkgs) lib25519 libcpucycles librandombytes; };
}
