{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    optionalString
    any
    attrValues
    ;

  types' = import ../../projects/types.nix { inherit lib; };
in
{
  options = {
    inherit (types'.example.getSubOptions { }) description module tests;
    example-snippet = mkOption {
      type = types.submodule ./code-snippet.nix;
      default.filepath = config.module;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        let
          button-missing-test = optionalString (any (test: test.module == null) (attrValues config.tests)) ''
            <button class="button missing">
            <a class = "heading" href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md" target = "_blank">Add missing test</a>
            </button>
          '';
        in
        ''
          <details><summary>${self.description}</summary>
          ${self.example-snippet}
          ${button-missing-test}
          </details>
        '';
    };
  };
}
