{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Interactive TLS-capable intercepting HTTP proxy";
    subgrants = [
      "mitmproxy"
    ];
  };

  nixos.programs = {
    mitmproxy = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
