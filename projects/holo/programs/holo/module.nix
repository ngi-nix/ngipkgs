{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.holo;
in
{
  options.programs.holo = {
    enable = lib.mkEnableOption "holo";
    package = lib.mkPackageOption pkgs "holo-cli" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # FIX: remove after this is merged:
      # https://github.com/NixOS/nixpkgs/pull/425724
      (cfg.package.overrideAttrs rec {
        pname = "holo-cli";
        version = "0.5.0-unstable-2025-07-01";
        src = fetchFromGitHub {
          owner = "holo-routing";
          repo = "holo-cli";
          rev = "f04c1d0dcd6d800e079f33b8431b17fa00afeeb1";
          hash = "sha256-ZJeXGT5oajynk44550W4qz+OZEx7y52Wwy+DYzrHZig=";
        };
        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit pname version src;
          hash = "sha256-bsoxWjOMzRRtFGEaaqK0/adhGpDcejCIY0Pzw1HjQ5U=";
        };
      })
    ];
  };
}
