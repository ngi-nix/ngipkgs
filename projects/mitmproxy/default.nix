{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Interactive TLS-capable intercepting HTTP proxy";
    subgrants = [
      "mitmproxy"
    ];
  };

  nixos.modules.programs = {
    mitmproxy = {
      module = ./module.nix;
    };
  };
  nixos.demo.shell = {
    module = ./demo.nix;
    description = "";
    tests.demo.module = null;
  };
}
