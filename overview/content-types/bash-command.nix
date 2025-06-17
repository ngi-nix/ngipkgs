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
  imports = [ ./shell-command.nix ];
  config.prompt = lib.mkDefault "$";
}
