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
          platform = "Arch Linux, Debian Sid/Trixie and Ubuntu 25.04";
          shell-session.bash = [
            {
              input = ''
                nix-build ./default.nix && ./result
              '';
            }
          ];
        }
        {
          platform = "Ubuntu 24.04/24.10";
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
          tests = lib.attrValues self.demo.tests;
          nullTests = lib.any (test: test.module == null) tests;
          markdownToHtml = markdown: "{{ markdown_to_html(${builtins.toJSON markdown}) }}";
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
              ${
                if (with self.demo; (description == null || description == "") && usage-instructions == [ ]) then
                  ''
                    <li><span class="option-alert">Missing</span>
                      <a href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md">Contribute usage instructions.</a>
                    </li>
                  ''
                else
                  ''
                    <li>
                      <strong>Usage Instructions</strong>
                      ${
                        if (self.demo.usage-instructions != [ ]) then
                          ''
                            <ol>
                              ${lib.concatMapStrings (i: ''
                                <li>
                                <p>${markdownToHtml i.instruction}</p>
                                </li>
                              '') self.demo.usage-instructions}
                            </ol>
                          ''
                        else
                          self.demo.description
                      }
                    </li>
                  ''
              }
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
