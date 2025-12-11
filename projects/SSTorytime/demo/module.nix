{
  pkgs,
  ...
}:

{
  # install tools (N4L, searchN4L, ...)
  programs.sstorytime.enable = true;

  services.sstorytime = {
    enable = true;
    port = 3030;
    openFirewall = true;
    createLocalDatabase = true;
  };
}
