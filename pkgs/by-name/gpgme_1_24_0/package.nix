{
  python3,
  gpgme,
  fetchurl,
  lib,
  swig,
}:
let
  gpgme_1_24_0 = gpgme.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "1.24.0";
      src = fetchurl {
        url = "mirror://gnupg/gpgme/gpgme-${finalAttrs.version}.tar.bz2";
        hash = "sha256-YeOmrYkyP+z6/xdrwXKPuMMxLy+qg0JNnVB3uiD199o=";
      };
      patches =
        if lib.versionAtLeast previousAttrs.version finalAttrs.version then
          previousAttrs.patches
        else
          lib.lists.drop 1 previousAttrs.patches;
      postPatch =
        if lib.versionAtLeast previousAttrs.version finalAttrs.version then
          previousAttrs.postPatch
        else
          null;
    }
  );
in
python3.pkgs.buildPythonPackage {
  pname = "gpgme";
  inherit (gpgme_1_24_0) version src patches;
  pyproject = true;

  postPatch = ''
    substituteInPlace lang/python/setup.py.in \
      --replace-fail "gpgme_h = '''" "gpgme_h = '${lib.getDev gpgme_1_24_0}/include/gpgme.h'"
  '';

  configureFlags = gpgme_1_24_0.configureFlags ++ [
    "--enable-languages=python"
  ];

  postConfigure = "
    cd lang/python
  ";

  preBuild = ''
    make copystamp
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  nativeBuildInputs = [
    swig
  ];

  buildInputs = [
    gpgme_1_24_0
  ];

  pythonImportsCheck = [ "gpg" ];

  meta = gpgme_1_24_0.meta // {
    description = "Python bindings to the GPGME API of the GnuPG cryptography library";
    homepage = "https://dev.gnupg.org/source/gpgme/browse/master/lang/python/";
  };
}
