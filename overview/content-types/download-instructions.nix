{
  config,
  lib,
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
    pkg = {
      type = types.package;
    };
    download-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
      default.instructions = [
        {
          # (ab)use of the platform arg :(
          platform = "nix-build";
          shell-session.bash = [
            {
              input = ''
                nix-build https://github.com/ngi-nix/ngipkgs/tarball/main -A
              '';
            }
          ];
        }
        # TODO:
        # {
        #   # (ab)use of the platform arg :(
        #   platform = "nix build";
        #   shell-session.bash = [
        #     {

        #     }
        #   ];
        # }
      ];
    };
    run-instructions = mkOption {
      type = types.submodule ./shell-instructions.nix;
      default.instructions.bash = [
        {
          input = ''
            ./result/bin/
          '';
        }
      ];
    };

    __toString = mkOption {
      type = with types; functionTo str;
      default = self: ''
        ${self.heading}

        <ol>
          <li>
            <strong>Download Binary</strong>
            ${config.download-instructions}
          </li>
          <li>
            <strong>Run Binary</strong>
            ${config.run-instructions}
          </li>
        </ol>
      '';
    };
  };
}
