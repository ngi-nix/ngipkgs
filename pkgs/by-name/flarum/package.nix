{
  fetchFromGitHub,
  fetchurl,
  lib,
  php,
}: let
  inherit
    (lib)
    licenses
    ;
in
  php.buildComposerProject (finalAttrs: {
    pname = "flarum";
    version = "1.8.0";

    src = fetchFromGitHub {
      owner = "flarum";
      repo = "flarum";
      rev = "v${finalAttrs.version}";
      hash = "sha256-xadZIdyH20mxfxCyiDRtSRSrPj8DWXpuup61WSsjgWw=";
    };

    composerLock = ./composer.lock;
    composerStrictValidation = false;
    vendorHash = "sha256-G/EPHcvcppuyAC0MAzE11ZjlOSTlphQrHnO3yS4+j5g=";

    meta = {
      changelog = "https://github.com/flarum/framework/blob/main/CHANGELOG.md";
      description = "Flarum is a delightfully simple discussion platform for your website";
      homepage = "https://github.com/flarum/flarum";
      license = lib.licenses.mit;
      ngi = {
        project = "Flarum";
        options = [["services" finalAttrs.pname]];
      };
    };
  })
