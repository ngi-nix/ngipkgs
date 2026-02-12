# nix-shell --run 'update PACKAGE_NAME true'
# The second boolen parameter is optional and controls whether to commit the update.
{
  lib,
  writeShellApplication,
  sources,
}:
(writeShellApplication {
  name = "update";
  text = ''
    ${lib.readFile ./update.sh}
    update "${sources.nixpkgs}" "$@"
  '';
  meta.description = "updates an NGIpkgs package";
})
