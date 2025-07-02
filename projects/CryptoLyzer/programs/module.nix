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
    package = lib.mkPackageOption pkgs [ "python3Packages" "cryptolyzer" ] { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    demo-shell.cryptolyzer = {
      programs = {
        cryptolyzer = cfg.package;
      };
    };
  };
}
