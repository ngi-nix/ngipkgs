# nix-shell --run 'update PACKAGE_NAME true'
# The second boolen parameter is optional and controls whether to commit the update.
{
  lib,
  writeShellApplication,
  nix-update,
  sources,
}:
(writeShellApplication {
  name = "update";
  text = ''
    ${lib.readFile ./update.sh}
    update "${sources.nixpkgs}" "${lib.getExe nix-update}" "$@"
  '';
  meta.description = "updates an NGIpkgs package";
})
