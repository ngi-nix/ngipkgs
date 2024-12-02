{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs) mitmproxy;
  };
}
