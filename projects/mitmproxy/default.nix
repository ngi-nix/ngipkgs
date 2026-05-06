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
        tests.basic.problem.broken.reason = ''
          Broken in nixpkgs, fix: https://github.com/NixOS/nixpkgs/pull/504385
        '';
      };
    };
  };
  nixos.demo.shell = {
    module = ./demo.nix;
    module-demo = ./module-demo.nix;
    description = "";
    tests.demo.module = pkgs.nixosTests.mitmproxy;
    tests.demo.problem.broken.reason = ''
      Broken in nixpkgs, fix: https://github.com/NixOS/nixpkgs/pull/504385
    '';
  };
}
