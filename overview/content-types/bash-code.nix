{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  imports = [ ./shell-code.nix ];
  config.prompt = lib.mkDefault "$";
}
