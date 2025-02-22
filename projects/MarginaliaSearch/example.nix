{
  config,
  pkgs,
  ...
}: {
  services.marginalia-search = {
    enable = true;
  };
}
