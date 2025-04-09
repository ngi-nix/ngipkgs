{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ tor-browser ];
  environment.variables.TOR_ENABLE_NAMECOIN = 1;
}
