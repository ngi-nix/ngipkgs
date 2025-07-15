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
    head
    removeSuffix
    splitString
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
    hasProblem = mkOption {
      type = with types; nullOr bool;
      default = null;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self:
        let
          # NOTE: we can render `self.name` directly, but this might make the
          # overview feel cluttered
          #
          # programs or services
          type = head (splitString "." self.name);
        in
        ''
          <a
            class="deliverable-tag ${optionalString self.hasProblem "deliverable-has-problem"}"
            title="${self.name}${optionalString self.hasProblem " has a problem"}"
            href="/project/${self.project-name}#${self.name}"
          >
            ${removeSuffix "s" type}
          </a>
        '';
    };
  };
}
