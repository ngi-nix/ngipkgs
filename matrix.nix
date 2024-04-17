{
  lib,
  self,
}: let
  job = system: attr: pkg: {
    # Name used to derive the name of the job. Visible in GitHub user interface.
    name = pkg.pname or pkg.name or attr;

    # The flake output attribute
    # <https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix#flake-output-attribute>
    # that should be built.
    attribute = ".#checks.${system}.\"${attr}\"";

    # The hash of the default output of the derivation.
    # This can be used to query a cache/store.
    digest = lib.substring (lib.stringLength "/nix/store/") 32 pkg."${lib.head pkg.outputs}Path";

    # The platform that the resulting job should build on.
    platform =
      lib.toList
      {
        "x86_64-linux" = "ubuntu-22.04";
        "x86_64-darwin" = "macos-12";
      }
      .${system};
  };
in {
  include = lib.flatten (lib.mapAttrsToList (system: lib.mapAttrsToList (job system)) self.outputs.checks);
}
