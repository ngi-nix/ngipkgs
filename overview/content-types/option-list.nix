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
    ;
in
{
  options = {
    prefix = mkOption {
      type = with types; listOf str;
    };
    module = mkOption {
      type = with lib.types; nullOr deferredModule;
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
      readOnly = true;
      default =
        self:
        let
          option-header =
            ''
              <span ${optionalString (self.module == null) ''class="option-alert"''}
              >${join "." self.prefix}</span>
            ''
            + optionalString (self.module == null) ''
              <a href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md">Implement missing module</a>
            '';
        in
        optionalString (self.project-options != [ ] || self.module == null) ''
          <details><summary>${option-header}</summary>
          <dl>${concatLines (map toString self.project-options)}</dl>
          </details>
        '';
    };
  };
}
