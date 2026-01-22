{
  writeShellApplication,
  jq,
}:
writeShellApplication {
  name = "metrics-summary";
  runtimeInputs = [ jq ];
  text = ''
    nix eval --option allow-import-from-derivation true --json -f default.nix metrics.summary | jq
  '';
  meta.description = "repository metrics";
}
