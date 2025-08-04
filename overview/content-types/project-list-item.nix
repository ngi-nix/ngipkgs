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
    name = mkOption {
      type = types.str;
      default = name;
    };
    description = mkOption {
      type = with types; nullOr str;
    };
    deliverables = mkOption {
      type =
        with types;
        listOf (submodule {
          options = {
            name = mkOption {
              type = str;
            };
            type = mkOption {
              type = enum [
                "program"
                "service"
                "demo"
              ];
            };
            hasProblem = mkOption {
              type = nullOr bool;
              default = null;
            };
          };
        });
      default = [ ];
    };
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self: with lib; ''
          <article class="project">
            <div class="row">
              <h2>
                <a href="/project/${self.name}">${self.name}</a>
              </h2>
              ${concatStringsSep "\n" (
                map (deliverable: ''
                  <a
                    class="deliverable-tag ${optionalString (deliverable.hasProblem) "deliverable-has-problem"}"
                    title="${deliverable.name} ${deliverable.type}${optionalString (deliverable.hasProblem) " has a problem"}"
                    href="/project/${self.name}#${
                      if deliverable.type != "demo" then "${deliverable.type}s.${deliverable.name}" else "demo"
                    }"
                  >
                    ${deliverable.type}
                  </a>
                '') self.deliverables
              )}
            </div>
            ${optionalString (!isNull self.description) ''
              <div class="description">
                ${self.description}
              </div>''}
          </article>
        '';
    };
  };
}
