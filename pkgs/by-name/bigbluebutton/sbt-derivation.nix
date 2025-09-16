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
      ### Shared src
      bbb-src = callPackage ./src { };

      ### Individual components
      ### Based on the listing in .github/workflows/automated-tests.yml
      bbb-apps-akka = callPackage ./bbb-apps-akka { };

      bbb-common-message = callPackage ./bbb-common-message { };
    };
in
lib.makeScope newScope packages
