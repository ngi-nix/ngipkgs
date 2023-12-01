# This module is used with configuraion examples, to obtain
#
#   config.system.build.toplevel
#
# without configuring any specific boot, i.e. no contaner (`boot.isContainer`)
# or virtualisation ("${modulesPath}/virtualisation/qemu-vm.nix").
# Of course, the resulting system is (by default) unbootable,
# which might appear useless.
# However, evaluation of the toplevel is slightly faster, and boot can
# be restored by
#
#    unbootable = pkgs.lib.mkForce false;
#
# or simply setting
#
#    boot.initrd.enable
#    boot.kernel.enable
#    boot.loader.grub.enable
#
# accordingly.
{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkIf
    types
    mkOption
    mkDefault
    ;
in {
  options = {
    unbootable = mkOption {
      type = types.bool;
      default = false;
      description = "Prevent the system from booting.";
    };
  };
  config = mkIf config.unbootable {
    boot = {
      initrd.enable = mkDefault false;
      kernel.enable = mkDefault false;
      loader.grub.enable = mkDefault false;
    };
  };
}
