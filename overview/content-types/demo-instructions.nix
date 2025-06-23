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
      default = ''
        <li>
          <strong>Install Nix</strong>
          ${config.installation-instructions}
        </li>
      '';
    };
    set-nix-config = mkOption {
      type = types.submodule ./shell-instructions.nix;
      default = ''
        <li>
          <strong>Enable binary substituters</strong>
          ${config.set-nix-config}
        </li>
      '';
    };
    build-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
      default = ''
        <li>
          <strong>Build and run a virtual machine</strong>
          ${config.build-instructions}
        </li>
      '';
    };
    demo = mkOption {
      type = types.submodule ./demo.nix;
      default = ''
        <li>
          <strong>Download a configuration file</strong>
          ${config.demo}
        </li>
      '';
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
              ${self.installation-instructions}
              ${self.demo}
              ${self.set-nix-config}
              ${self.build-instructions}
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
