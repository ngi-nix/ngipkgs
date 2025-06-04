{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
types.submodule (
  { name, ... }:
  {
    options = {
      type = mkOption {
        type = types.enum [
          "vm"
          "shell"
        ];
        default = if name == "demo-shell" then "shell" else "vm";
      };
      servicePort = mkOption {
        type = types.port;
        default = 0;
      };
      instructions = mkOption {
        type =
          with types;
          submodule {
            installNix = mkOption {
              type = types.str;
              default = ''
                <strong>Install Nix</strong>
                <ul>
                  <li>Arch Linux</li>
                    <pre><code>pacman --sync --refresh --noconfirm curl git jq nix</code></pre>
                  <li>Debian/Ubuntu</li>
                    <pre><code>apt install --yes curl git jq nix</code></pre>
                </ul>
              '';
            };
            downloadConfig = mkOption {
              type = types.str;
            };
            substituters = mkOption {
              type = types.str;
              default = ''
                <strong>Enable binary substituters</strong>
                  <pre><code>NIX_CONFIG='substituters = https://cache.nixos.org/ https://ngi.cachix.org/'$'\n'''trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw='</code></pre>
                  <pre><code>export NIX_CONFIG</code></pre>
              '';
            };
            build = mkOption {
              type = types.str;
              default = ''
                <strong>Build and run a ${if name == "demo-shell" then "shell" else "virtual machine"}</strong>
                  <ul>
                    <li>Arch Linux, Debian Sid and Ubuntu 25.04</li>
                      <pre><code>nix-build ./default.nix && ./result</code></pre>
                    <li>Debian 12 and Ubuntu 24.04/24.10</li>
                      <pre><code>rev=$(nix-instantiate --eval --attr sources.nixpkgs.rev https://github.com/ngi-nix/ngipkgs/archive/master.tar.gz | jq --raw-output)</code></pre>
                      <pre><code>nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz --packages nix --run "nix-build ./default.nix && ./result"</code></pre>
                  </ul>
              '';
            };
          };
      };
      __toString = mkOption {
        type = with types; functionTo str;
        readOnly = true;
        default =
          self: with lib; ''
            <ol>
              ${mapAttrsToList (instruction: value: ''
                <li>
                  value
                </li>
              '') self.instructions}
              ${optionalString (self.servicePort != 0) ''
                <li>
                  <strong>Access the service</strong><br />
                    Open a web browser at <a href="http://localhost:${toString self.servicePort}">http://localhost:${toString self.servicePort}</a> .
                </li>
              ''}
            </ol>
          '';
      };
    };
  }
)
