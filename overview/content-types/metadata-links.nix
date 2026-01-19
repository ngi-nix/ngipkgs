{
  lib,
  ngiTypes,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    optionalString
    concatMapAttrsStringSep
    ;
in
{
  options = {
    inherit (ngiTypes.metadata.getSubOptions { }) links;

    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        let
          links = lib.filterAttrs (_: v: v != null) self.links;
        in
        (optionalString (links != null && links != { })) ''
          <p>
          Related links:
            <ul>
            ${lib.concatMapAttrsStringSep "\n" (_: attr: ''
              <li>
                <a href="${attr.url}">${attr.text}</a>
              </li>
            '') links}
            </ul>
          </p>
        '';
    };
  };
}
