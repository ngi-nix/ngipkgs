{
  newScope,
  lib,
  mkSbtDerivation,
}:

let
  packages =
    self:
    let
      callPackage = self.newScope {
        inherit mkSbtDerivation;
      };
    in
    {
      ### Things shared between multiple components
      bbb-shared-utils = rec {
        src = callPackage ./src { };

        versionBase = src.version;

        # All components have internal versions, some components are just projects fetched from elsewhere.
        # Don't try tracking every package's version, just add a note whose version this really is.
        versionComponent = "${versionBase}-bigbluebutton";

        postPatch = ''
          patchShebangs build/setup-inside-docker.sh build/packages-template

          # This is for setting up cache persistency in docker across runs. We don't want this.
          substituteInPlace build/setup-inside-docker.sh \
            --replace-fail 'ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' '#ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' \
            --replace-fail 'CACHE_DIR="/root/"' 'CACHE_DIR="''${SOURCE}/cache/"'
        '';

        meta = {
          description = "Complete web conferencing system for virtual classes and more";
          homepage = "https://bigbluebutton.org";
          license = lib.licenses.lgpl3Only;
          teams = [
            lib.teams.ngi
          ];
          platforms = lib.platforms.linux;
        };
      };

      ### Individual components
      ### Based on the listing in .github/workflows/automated-tests.yml
      bbb-apps-akka = callPackage ./bbb-apps-akka { };

      bbb-common-message = callPackage ./bbb-common-message { };
    };
in
lib.makeScope newScope packages
