{
  lib,
  ngiTypes,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    inherit (ngiTypes.metadata.getSubOptions { }) subgrants;

    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        let
          inherit (lib)
            concatMapAttrsStringSep
            concatMapStrings
            isAttrs
            isList
            optionalString
            ;

          subgrants-list = ''
            <ul>
            ${concatMapStrings (subgrant: ''
              <li>
              <a href="https://nlnet.nl/project/${subgrant}">${subgrant}</a>
              </li>
            '') self.subgrants}
            </ul>
          '';

          subgrants-attrset = ''
            <dl class="subgrant-list">
            ${concatMapAttrsStringSep "\n" (name: subgrants: ''
              ${optionalString (subgrants != [ ]) ''
                <dt>${name}</dt>
                ${concatMapStrings (subgrant: ''
                  <dd>
                  <a href="https://nlnet.nl/project/${subgrant}">${subgrant}</a>
                  </dd>
                '') subgrants}
              ''}
            '') self.subgrants}
            </dl>
          '';
        in
        optionalString (self.subgrants != null) ''
          <p>
          This project is funded by NLnet through these subgrants:
            ${optionalString (isList self.subgrants) subgrants-list}
            ${optionalString (isAttrs self.subgrants) subgrants-attrset}
          </p>
        '';
    };
  };
}
