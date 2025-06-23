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
          nullTests = lib.elem null (lib.attrValues self.demo.tests);
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
            </ol>
          ''
        else
          lib.optionalString (self.demo.problem != null) ''
            <dt>Problems:</dt>
            <dd><span class="option-alert">Demo</span> ${
              lib.concatMapAttrsStringSep "\n" (name: value: value.reason) self.demo.problem
            }</dd>
          ''
          + lib.optionalString nullTests ''
            <dd><span class="option-alert">Demo</span>
              Tests are missing for the demo.
            </dd>
          '';
    };
  };
}
