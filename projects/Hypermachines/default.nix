{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs)
      autobase
      corestore
      hyperbeam
      hyperblobs
      hypercore
      hyperswarm
      ;
  };
}
