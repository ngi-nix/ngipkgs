{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Interactive TLS-capable intercepting HTTP proxy";
    subgrants.Entrust = [
      "mitmproxy"
    ];
  };

  nixos.modules.programs = {
    mitmproxy = {
      module = ./module.nix;
      examples.basic = {
        module = ./demo.nix;
        description = "";
        tests.basic.module = pkgs.nixosTests.mitmproxy;
      };
    };
  };
  nixos.demo.shell = {
    module = ./demo.nix;
    module-demo = ./module-demo.nix;
    description = "";
    tests.demo.module = pkgs.nixosTests.mitmproxy;
  };
}
