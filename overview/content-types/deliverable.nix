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
    type = mkOption {
      type = types.enum [
        "program"
        "service"
        "demo"
      ];
    };
    hasProblem = mkOption {
      type = with types; nullOr bool;
      default = null;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default = self: ''
        <a
          class="deliverable-tag ${optionalString self.hasProblem "deliverable-has-problem"}"
          title="${self.name} ${self.type}${optionalString self.hasProblem " has a problem"}"
          href="/project/${self.name}#${self.type}"
        >
          ${self.type}
        </a>
      '';
    };
  };
}
