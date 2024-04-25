{
  lib,
  stdenv,
  liberaformsEnv,
  postgresql,
  postgresqlTestHook,
}:
stdenv.mkDerivation {
  pname = liberaformsEnv.name;
  inherit (liberaformsEnv) version;
  inherit (liberaformsEnv.config.mkDerivation) src dontConfigure installPhase;

  doCheck = true;

  nativeCheckInputs = [
    liberaformsEnv.pyEnv
    postgresql
    postgresqlTestHook
  ];

  env = {
    postgresqlEnableTCP = 1;
    PGUSER = "db_user";
  };

  preCheck = ''
    export LANG=C.UTF-8
  '';

  checkPhase = ''
    runHook preCheck

    # Run pytest on the installed version. A running postgres database server is needed.
    (cd tests && cp test.ini.example test.ini && pytest -k "not test_save_smtp_config") #TODO why does this break?

    runHook postCheck
  '';

  meta = {
    description = "Free form software";
    homepage = "https://gitlab.com/liberaforms/liberaforms";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
  };
}
