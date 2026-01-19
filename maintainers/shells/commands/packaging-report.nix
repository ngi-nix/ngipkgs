{ writeShellApplication, jq }:
writeShellApplication {
  name = "packaging-report";
  runtimeInputs = [ jq ];
  text = ''
    nix build --option allow-import-from-derivation true -f default.nix report.packaging
  '';
  meta.description = "Packaging and repository content summary";
}
