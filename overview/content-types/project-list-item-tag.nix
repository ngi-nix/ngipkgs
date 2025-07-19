{
  lib,
  name,
  config,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    optionalString
    ;
in
{
  options = {
    name = mkOption {
      type = types.str;
    };
    project-name = mkOption {
      type = types.str;
      internal = true;
    };
    module = mkOption {
      type = with types; nullOr deferredModule;
    };
    type = mkOption {
      type = types.enum [
        "program"
        "service"
        "demo"
      ];
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self:
        let
          hasProblem = self.module == null;
        in
        ''
          <a
            class="deliverable-tag ${optionalString hasProblem "deliverable-has-problem"}"
            title="${self.name}${optionalString hasProblem " has a problem"}"
            href="/project/${self.project-name}#${self.name}"
          >
            ${self.type}
          </a>
        '';
    };
  };
}
