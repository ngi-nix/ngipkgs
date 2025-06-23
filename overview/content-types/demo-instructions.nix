{
  lib,
  pkgs,
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
      default.instructions = [
        {
          platform = "Arch Linux";
          shell-session.bash = [
            {
              input = ''
                pacman --sync --refresh --noconfirm curl git jq nix
              '';
            }
          ];
        }
        {
          platform = "Debian";
          shell-session.bash = [
            {
              input = ''
                apt install --yes curl git jq nix
              '';
            }
          ];
        }
        {
          platform = "Ubuntu";
          shell-session.bash = [
            {
              input = ''
                apt install --yes curl git jq nix
              '';
            }
          ];
        }
      ];
    };
    nix-config = mkOption {
      type = types.submodule {
        imports = [ ./nix-config.nix ];
        _module.args.pkgs = pkgs;
      };
      default.settings = {
        substituters = [
          "https://cache.nixos.org/"
          "https://ngi.cachix.org/"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6nchdd59x431o0gwypbmraurkbj16zpmqfgspcdshjy="
          "ngi.cachix.org-1:n+cal72roc3qqulxihpv+tw5t42whxmmhpragkrsrow="
        ];
      };
    };
    set-nix-config = mkOption {
      type = types.submodule ./shell-instructions.nix;
      default.instructions.bash = [
        {
          input = ''
            export NIX_CONFIG='${config.nix-config}'
          '';
        }
      ];
    };
    build-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
      default.instructions = [
        {
          platform = "Arch Linux, Debian Sid and Ubuntu 25.04";
          shell-session.bash = [
            {
              input = ''
                nix-build ./default.nix && ./result
              '';
            }
          ];
        }
        {
          platform = "Debian 12 and Ubuntu 24.04/24.10";
          shell-session.bash = [
            {
              input = ''
                rev=$(nix-instantiate --eval --attr sources.nixpkgs.rev https://github.com/ngi-nix/ngipkgs/archive/master.tar.gz | jq --raw-output)
              '';
            }
            {
              input = ''
                nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz --packages nix --run "nix-build ./default.nix && ./result"
              '';
            }
          ];
        }
      ];
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
                ${config.installation-instructions}
              </li>
              <li>
                <strong>Download a configuration file</strong>
                ${config.demo}
              </li>
              <li>
                <strong>Enable binary substituters</strong>
                ${config.set-nix-config}
              </li>
              <li>
                <strong>Build and run a virtual machine</strong>
                ${config.build-instructions}
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
