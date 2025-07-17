{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    optionalString
    ;

  types' = import ../../projects/types.nix { inherit lib; };
in
{
  options = {
    inherit (types'.metadata.getSubOptions { }) subgrants;

    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        (optionalString (self.subgrants != null && self.subgrants != [ ])) ''
          <p>
          This project is funded by NLnet through these subgrants:
            <ul>
            ${lib.concatMapStrings (subgrant: ''
              <li>
                <a href="https://nlnet.nl/project/${subgrant}">${subgrant}</a>
              </li>
            '') self.subgrants}
            </ul>
          </p>
        '';
    };
  };
}
