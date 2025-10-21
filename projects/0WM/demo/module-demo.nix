{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.zwm-client;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.autoLogin.user = "nixos";

    programs.chromium.enable = true;
    programs.chromium.extensions = [
      "cgffilbpcibhmcfbgggfhfolhkfbhmik" # Immersive Web Emulator (XR)
      "lfhmikememgdcahcdlaciloancbhjino" # CORS Unblock
    ];

    environment.systemPackages = with pkgs; [
      _0wm-ap-mock
      _0wm-opmode
      chromium
      xdotool # automate clicks
    ];

    # browser requires more memory
    virtualisation.memorySize = 4096;

    networking.firewall.allowedTCPPorts = [
      8001 # opmode
      8002 # client
      8003 # ap mock
    ];
  };
}
