{
  pkgs,
  sources,
  ...
}:
{
  packages = {
    inherit (pkgs) omnom;
  };
  nixos = {
    # https://github.com/asciimoo/omnom/blob/master/config/config.go
    modules.services.omnom = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/omnom.nix";
    examples.base = {
      path = ./example.nix;
      description = "Basic Omnom configuration, mainly used for testing purposes.";
    };
    tests = null;
  };
}
