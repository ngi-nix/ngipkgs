{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.cryptolyzer;
in
{
  options.programs.cryptolyzer = {
    enable = lib.mkEnableOption "CryptoLyzer";
    package = lib.mkPackageOption pkgs.python3Packages "cryptolyzer" { };
  };
  config.environment.systemPackages = lib.mkIf cfg.enable [ cfg.package ];
}
