{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    optionalString
    concatMapAttrsStringSep
    ;

  types' = import ../../projects/types.nix { inherit lib; };
in
{
  options = {
    inherit (types'.metadata.getSubOptions { }) links;

    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        (optionalString (self.links != null && self.links != { })) ''
          <p>
          Related links:
            <ul>
            ${lib.concatMapAttrsStringSep "\n" (_: attr: ''
              <li>
                <a href="${attr.url}">${attr.text}</a>
              </li>
            '') self.links}
            </ul>
          </p>
        '';
    };
  };
}
