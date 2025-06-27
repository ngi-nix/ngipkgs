{
  lib,
  name,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    heading = mkOption {
      type = types.str;
    };
    installation-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
    };
    set-nix-config = mkOption {
      type = types.submodule ./shell-instructions.nix;
    };
    build-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
    };
    demo = mkOption {
      type = types.submodule ./demo.nix;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      # TODO: refactor?
      default =
        self:
        let
          tests = lib.attrValues self.demo.tests;
          nullTests = lib.any (test: test.module == null) tests;
        in
        if (self.demo.problem == null && !nullTests) then
          ''
            ${self.heading}

            <ol>
              <li>
                <strong>Install Nix</strong>
                ${self.installation-instructions}
              </li>
              <li>
                <strong>Download a configuration file</strong>
                ${self.demo}
              </li>
              <li>
                <strong>Enable binary substituters</strong>
                ${self.set-nix-config}
              </li>
              <li>
                <strong>Build and run a virtual machine</strong>
                ${self.build-instructions}
              </li>
              ${lib.optionalString (with self.demo; description == null || description == "") ''
                <li><span class="option-alert">Missing</span>
                  <a href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md">Contribute usage instructions.</a>
                </li>
              ''}
            </ol>
          ''
        else
          ''
            ${self.heading}

            <ul>
            ${
              lib.optionalString nullTests ''
                <li><span class="option-alert">Missing</span>
                  <a href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md">Contribute tests for the demo.</a>
                </li>
              ''
              + lib.optionalString (self.demo.problem != null) ''
                <li><span class="option-alert">Problem</span> ${
                  lib.concatMapAttrsStringSep "\n" (name: value: value.reason) self.demo.problem
                }</li>
              ''
            }
            </ul>
          '';
    };
  };
}
