{
  runCommand,
  atomic-server,
}:
runCommand "atomic-cli" {
  meta = {
    inherit (atomic-server.meta) description homepage license;
    mainProgram = "atomic-cli";
  };
} ''
  mkdir -p "$out/bin"
  ln -s "${atomic-server}/bin/atomic-cli" "$out/bin/atomic-cli"
''
