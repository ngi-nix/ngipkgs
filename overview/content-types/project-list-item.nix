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
      type = with types; listOf (submodule ./deliverable.nix);
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
              ${concatLines (map toString self.deliverables)}
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
