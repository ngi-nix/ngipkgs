{
  lib,
  config,
  pkgs,
  ...
}:
{
  config.activate = pkgs.writeShellScript "demo-vm" ''
    exec ${config.system.build.vm}/bin/run-nixos-vm "$@"
  '';
}
