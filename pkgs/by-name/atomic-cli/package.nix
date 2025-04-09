{
  runCommand,
  atomic-server,
}:
runCommand "atomic-cli"
  {
    pname = "atomic-cli";
    inherit (atomic-server) version;
    meta = {
      inherit (atomic-server.meta) description homepage license;
      mainProgram = "atomic-cli";
    };
  }
  ''
    mkdir -p "$out/bin"
    ln -s "${atomic-server}/bin/atomic-cli" "$out/bin/atomic-cli"
  ''
