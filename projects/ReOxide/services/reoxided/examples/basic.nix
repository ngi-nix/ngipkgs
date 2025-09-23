{ lib, ... }:
{
  programs.reoxide.enable = true;
  services.reoxided = {
    enable = true;
    ghidraInstall = [
      {
        enabled = lib.mkForce true;
      }
    ];
  };
}
