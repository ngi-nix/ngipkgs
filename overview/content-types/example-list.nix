{
  lib,
  utils,
  ...
}:
let
  inherit (lib) types mkOption;
in
{
  options = {
    examples = mkOption {
      type = with types; listOf (utils.submoduleWithArgs ./example.nix);
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self:
        let
          heading = ''
            <a class="heading" href="#examples">
              <h2 id="examples">
                Examples
                <span class="anchor"/>
              </h2>
            </a>
          '';
          button-add-example = ''
            <button class="button example">
            <a class = "heading" href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md#how-to-add-an-example" target ="_blank">Add an example</a>
            </button>
          '';
        in
        ''
          ${heading}
          ${lib.concatLines (map toString self.examples)}
          ${button-add-example}
        '';
    };
  };
}
