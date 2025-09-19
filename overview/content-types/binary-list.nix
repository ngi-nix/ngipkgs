{
  lib,
  pkgs,
  utils,
  ngiTypes,
  ...
}:
let
  inherit (lib)
    types
    mkOption

    attrValues
    concatLines
    head
    mapAttrs
    optionalString
    pipe
    ;
in
{
  options = {
    binaries = mkOption {
      type = with types; attrsOf ngiTypes.binary;
      default = { };
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default =
        self:
        let
          binaryRender =
            _: binary:
            # TODO: render missing binaries
            optionalString (binary.data != null) ''
              <li>${binary.name}</li>
            '';
          first-available-binary = (head (attrValues self.binaries)).name;
          binary-example-snippet = utils.eval rec {
            imports = [ ./code-snippet.nix ];
            snippet-text = ''
              # test.nix
              {
                ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/main") { },
                # Extend Nixpkgs package set with NGIpkgs
                pkgs ? ngipkgs.pkgs.extend ngipkgs.overlays.default,
              }:
              {
                ${first-available-binary} = pkgs.${first-available-binary};
              }
            '';
            filepath = pkgs.writeText "binary-example-${first-available-binary}" snippet-text;
          };
          binary-example-build = utils.eval {
            imports = [ ./bash-command.nix ];
            input = ''
              nix-build -A ${first-available-binary} test.nix
            '';
          };
        in
        optionalString (self.binaries != { }) ''
          <a class="heading" href="#binaries">
            <h2 id="binaries">
              Binary files
              <span class="anchor"/>
            </h2>
          </a>

          Binaries are available under `pkgs.BINARY_NAME`, for example:

          ${binary-example-snippet}

          Which, you can build with:

          ${binary-example-build}

          <a class="heading" href="#available-binaries">
            <h3 id="available-binaries">
              Available binaries:
              <span class="anchor"/>
            </h2>
          </a>

          <ul>
            ${pipe self.binaries [
              (mapAttrs binaryRender)
              attrValues
              concatLines
            ]}
          </ul>
        '';
    };
  };
}
