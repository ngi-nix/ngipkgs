{
  pkgs,
  ...
}:
{
  environment.systemPackages = [ pkgs.taler-wallet-core ];
}
