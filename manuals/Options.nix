{
  lib,
  modulesPath,
  nixos-modules,
  nixosOptionsDoc,
  pkgs,
  revision,
  writeText,
  ...
}:
rec {
  optionsDoc = nixosOptionsDoc {
    inherit revision;
    options =
      lib.flip lib.removeAttrs [ "_module" ]
        (lib.evalModules {
          class = "nixos";
          specialArgs = {
            inherit pkgs modulesPath;
          };
          modules = [
            {
              config = {
                # Explanation: do not check anything
                # because NixOS options are not included.
                # See also comment in NixOS' `noCheckForDocsModule`.
                _module.check = false;
              };
              imports = lib.attrValues nixos-modules.programs ++ lib.attrValues nixos-modules.services;
            }
          ];
        }).options;
  };

  # NixOS' `nixos-render-docs options commonmark`
  # generates a markdown that is not compatible with MyST,
  # and assumes it's only used in the context of NixOS.
  #
  # Description: generates a valid MyST syntax from `manuals.optionsDoc.optionsNix`.
  optionsMyST =
    let
      fixContent =
        text:
        lib.replaceStrings
          [
            "(#opt-"
            "{.note}"
            "{.warning}"
            "{var}"
          ]
          [
            "(https://nixos.org/manual/nixos/unstable/#opt-"
            "{note}"
            "{warning}"
            "{option}"
          ]
          (lib.removeSuffix "\n" text);
      renderCode =
        arg:
        if lib.typeOf arg == "string" then
          fixContent arg
        else
          let
            text = fixContent arg.text;
          in
          if arg._type == "literalExpression" then
            if lib.match ".*\n.*" text == null then
              "`${lib.replaceStrings [ "`" ] [ "\\`" ] text}`"
            else
              ''

                ```
                ${lib.replaceStrings [ "```" ] [ "\\`\\`\\`" ] text}
                ```
              ''
          else if arg._type == "literalMD" then
            text
          else
            # FixMe(completeness): unsupported arg._type
            assert (lib.trace arg._type false);
            "";
      renderId = lib.concatMapStringsSep "-" (
        part:
        lib.concatStrings (
          lib.map (
            c: if "0" <= c && c <= "9" || "a" <= c && c <= "z" || "A" <= c && c <= "Z" then c else "_"
          ) (lib.stringToCharacters part)
        )
      );
    in
    writeText "generated.md" (
      lib.concatStringsSep "\n\n" (
        lib.concatAttrValues (
          lib.mapAttrs (optName: opt: [
            (
              ''
                {#option-${renderId opt.loc}}
                # `${optName}`
              ''
              + lib.optionalString opt.readOnly ''
                - ReadOnly: ${toString opt.readOnly}
              ''
              + ''
                - Type: `${opt.type}`
                - Description: ${renderCode opt.description}
              ''
              + lib.optionalString (opt ? "default") ''
                - Default: ${renderCode opt.default}
              ''
              + lib.optionalString (opt ? "example") ''
                - Example: ${renderCode opt.example}
              ''
            )
          ]) optionsDoc.optionsNix
        )
      )
    );
}
