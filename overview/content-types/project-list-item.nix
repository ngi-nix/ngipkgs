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
        # XXX(@fricklerhandwerk): this is very simple-minded. we'll need to think
        # about how to deal with cases where there are multiple services etc.
        submodule {
          options = {
            service = mkOption {
              type = types.bool;
              default = false;
            };
            program = mkOption {
              type = types.bool;
              default = false;
            };
            demos = ./demo-item.nix;
          };
        };
      default = { };
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
                mapAttrsToList (
                  deliverable: exists:
                  optionalString exists ''<a class="deliverable-tag" href="/project/${self.name}#${deliverable}">${deliverable}</a>''
                ) self.deliverables
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
