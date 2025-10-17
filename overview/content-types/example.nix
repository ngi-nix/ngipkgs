{
  lib,
  config,
  utils,
  ...
}:
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
    inherit (types'.example.getSubOptions { })
      description
      module
      name
      tests
      ;
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
            <a class = "heading" href="https://github.com/ngi-nix/ngipkgs/blob/main/maintainers/docs/project.md#libtest" target = "_blank">Add missing test</a>
            </button>
          '';

          declaration-link = utils.getFileDeclarationLink self.module;
        in
        ''
          <details open>
          <summary>${self.name}</summary>
          ${self.example-snippet}
          ${button-missing-test}

          ${optionalString (self.module != null) ''
            <p>Declared in: ${declaration-link}</p>
          ''}

          </details>
        '';
    };
  };
}
