# The top-level overview for all projects
{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types
    concatMapStringsSep
    attrValues
    length
    ;
  inherit (types)
    listOf
    nullOr
    functionTo
    str
    submodule
    ;
in
{
  options = {
    projects = mkOption {
      type = listOf (submodule ./project-list-item.nix);
    };
    version = mkOption {
      type = nullOr str;
    };
    lastModified = mkOption {
      type = nullOr str;
    };
    __toString = mkOption {
      type = functionTo str;
      readOnly = true;
      default = self: ''
        <section class="page-width">
          <h1>NGIpkgs</h1>

          <p>
            NGIpkgs is a collection of ${toString (length self.projects)} software applications funded by the <a href="https://www.ngi.eu/ngi-projects/ngi-zero/">Next Generation Internet</a> initiative and packaged for <a href="https://nixos.org">NixOS</a>.
          </p>

          <p>
            This service is still <strong>experimental</strong> and under active development.
            Don't expect anything specific to work yet:
          </p>

          <ul>
            <li>The package collection is far incomplete</li>
            <li>Many packages lack crucial components</li>
            <li>There are no instructions for getting started</li>
            <li>How software and the corresponding Nix expressions are exposed is subject to change</li>
          </ul>

          <p>
            More information about the project:
          </p>

          <ul>
            <li>
              <a href="https://github.com/ngi-nix/ngipkgs">Source code</a>
            </li>
            <li>
              <a href="https://github.com/ngi-nix/summer-of-nix/issues/41">Issue tracker</a>
            </li>
            <li>
              <a href="https://nixos.org/community/teams/ngi/">Nix@NGI team</a>
            </li>
          </ul>

        ${concatMapStringsSep "\n" toString (
          with lib; sortOn (project: toLower project.name) self.projects
        )}

        </section>

        <footer>Version: ${self.version}, Last Modified: ${self.lastModified}</footer>
      '';
    };
  };
}
