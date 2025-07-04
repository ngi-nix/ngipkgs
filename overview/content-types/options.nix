{
  lib,
  name,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    optionalString
    join
    concatLines
    attrValues
    ;
in
{
  options = {
    prefix = mkOption {
      type = with types; listOf str;
    };
    project-options = mkOption {
      type =
        with types;
        listOf (submodule {
          imports = [ ./option.nix ];
          _module.args.pkgs = pkgs;
        });
      default = [ ];
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self:
        optionalString (self.project-options != [ ]) ''
          <details><summary><code>${join "." self.prefix}</code></summary><dl>
          ${concatLines (map toString self.project-options)}
          </dl></details>
        '';
    };
  };
}
