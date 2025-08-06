{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pagedjs;
in
{
  options.programs.pagedjs = {
    enable = lib.mkEnableOption "PagedJS";
    package = lib.mkPackageOption pkgs "pagedjs-cli" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
