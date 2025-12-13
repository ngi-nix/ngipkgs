{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.sylk;
in
{
  options.programs.sylk = {
    enable = lib.mkEnableOption "Sylk";
    package = lib.mkPackageOption pkgs "sylk" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      # sylk not available on aarch64-linux
      lib.optionals (lib.meta.availableOn pkgs.stdenv.hostPlatform cfg.package) [
        cfg.package
      ];
  };
}
