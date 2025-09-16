{
  newScope,
  lib,
  mkSbtDerivation,
}:

let
  packages =
    self:
    let
      inherit (self) callPackage;
    in
    {
      ### Shared src
      bbb-src = callPackage ./src { };

      ### Individual components
      ### Based on the listing in .github/workflows/automated-tests.yml
      bbb-apps-akka = callPackage ./bbb-apps-akka {
        inherit mkSbtDerivation;
      };

      bbb-common-message = callPackage ./bbb-common-message {
        inherit mkSbtDerivation;
      };
    };
in
lib.makeScope newScope packages
