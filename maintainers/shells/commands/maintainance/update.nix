# NOTE: currently, this only works with flakes, because `nix-update` can't
# find `maintainers/scripts/update.nix` otherwise
#
# nix-shell --run 'update PACKAGE_NAME --use-update-script'
{
  writeShellApplication,
  nix-update,
}:
(writeShellApplication {
  name = "update";
  runtimeInputs = [ nix-update ];
  text = ''
    package=$1; shift # past value
    nix-update --flake "$package" "$@"
  '';
  meta.description = "updates an NGIpkgs package (nix with flakes supported required)";
})
