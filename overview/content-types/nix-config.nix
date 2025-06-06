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
  options = {
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        let
          separator = "'$'\\n''";
          concatSettings = lib.concatStringsSep separator (
            lib.map (attrs: "${attrs.name} = ${toString attrs.value}") self.settings
          );
        in
        "NIX_CONFIG='${concatSettings}'";
    };
    settings = mkOption {
      type = with types; listOf (submodule ./config-item.nix);
    };
  };
}
