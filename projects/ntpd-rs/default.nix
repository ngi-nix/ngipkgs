{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) ntpd-rs;};
  nixos = {
    modules.services.ntpd-rs = null;
  };
}
