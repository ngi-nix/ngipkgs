{ ... }:
{
  programs.holo.enable = true;
  services.holo-daemon.enable = true;

  #TODO: Move this to the module confgiguration
  #      It is only needed for the demo
  services.getty.autologinUser = "root";
}
