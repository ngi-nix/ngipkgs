{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    optionalString
    any
    attrValues
    hasPrefix
    removePrefix
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

          declaration = toString self.module;

          isFlake = flake == ../../.;

          ngipkgs-path = toString (if isFlake then flake else ../../.) + "/";
          nixpkgs-path = toString flake.inputs.nixpkgs + "/";

          inNixpkgs = hasPrefix nixpkgs-path declaration;

          relative-file-path = removePrefix (if inNixpkgs then nixpkgs-path else ngipkgs-path) declaration;

          ngipkgs-rev = flake.rev or "main";

          src-url =
            if inNixpkgs then
              "https://github.com/nixos/nixpkgs/blob/${flake.inputs.nixpkgs.rev}/${relative-file-path}"
            else
              "https://github.com/ngi-nix/ngipkgs/blob/${ngipkgs-rev}/${relative-file-path}";
        in
        ''
          <details open>
          <summary>${self.name}</summary>
          ${self.example-snippet}
          ${button-missing-test}

          ${optionalString (self.module != null) ''
            <dl>
              <dt>Declared in:</dt>
              <dd class="option-type">
                <a href="${src-url}">${relative-file-path}</a>
              </dd>
            </dl>
          ''}

          </details>
        '';
    };
  };
}
