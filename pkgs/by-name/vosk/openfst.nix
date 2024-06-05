{
  lib,
  fetchFromGitHub,
  openfst
}:

openfst.overrideAttrs (oldAttrs: let
  baseVersion = "1.8.0";
in {
  pname = "openfst-alphacep";
  version = "${baseVersion}-unstable-2021-02-07";

  src = fetchFromGitHub {
    owner = "alphacep";
    repo = "openfst";
    rev = "7dfd808194105162f20084bb4d8e4ee4b65266d5";
    hash = "sha256-XiPR4AaSa/7OqYoYZOwlW3UhAsYmscBE36xffI2gPPg=";
  };

  strictDeps = true;

  passthru = (oldAttrs.passthru or {}) // {
    inherit baseVersion;
  };

  meta = {
    description = "${oldAttrs.meta.description} with fixes for Vosk";
    homepage = "https://github.com/alphacep/openfst";
    maintainers = with lib.maintainers; [ OPNA2608 ];
    inherit (oldAttrs.meta) license platforms;
  };
})
