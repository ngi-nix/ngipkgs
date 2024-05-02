{
  lib,
  config,
  dream2nix,
  ...
}: let
  version = "3.1.1";
  src = config.deps.fetchFromGitLab {
    owner = "liberaforms";
    repo = "liberaforms";
    rev = "v${version}";
    hash = "sha256-RpEaO/3jje/ABdIGrnBo1sYPHpuUuDfe4uuJON9RiqY=";
  };
in {
  imports = [dream2nix.modules.dream2nix.pip];

  deps = {nixpkgs, ...}: {
    inherit
      (nixpkgs)
      fetchFromGitLab
      file
      libxml2
      libxslt
      postgresql
      postgresqlTestHook
      runCommand
      substituteAll
      ;
    python = nixpkgs.python311;
  };

  name = "liberaforms";
  inherit version;

  buildPythonPackage.format = "other";

  mkDerivation = {
    inherit src;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      cp -R ${src}/. $out

      runHook postInstall
    '';

    doCheck = true;

    nativeCheckInputs = [
      config.deps.postgresql
      config.deps.postgresqlTestHook
      config.public.env
    ];

    preCheck = ''
      export LANG=C.UTF-8
      export PGUSER=db_user
      export postgresqlEnableTCP=1
    '';

    checkPhase = ''
      runHook preCheck

      # Run pytest on the installed version. A running postgres database server is needed.
      (cd tests && cp test.ini.example test.ini && pytest -k "not test_save_smtp_config") #TODO why does this break?

      runHook postCheck
    '';
  };

  public = {
    env = config.public.pyEnv;
    meta = {
      description = "Free form software";
      homepage = "https://gitlab.com/liberaforms/liberaforms";
      license = lib.licenses.agpl3Plus;
      platforms = lib.platforms.all;
    };
  };

  pip = {
    pypiSnapshotDate = "2024-04-01";
    requirementsFiles = ["${src}/requirements.txt"];
    requirementsList = [
      "factory-boy"
      "faker"
      "polib"
      "pytest-dotenv"
    ];
    nativeBuildInputs = [
      config.deps.postgresql
      config.deps.libxml2.dev
      config.deps.libxslt.dev
    ];
    pipFlags = [
      "--no-binary"
      "python-magic"
    ];
    overrides = {
      lxml = {
        mkDerivation = {
          nativeBuildInputs = [
            config.deps.libxml2.dev
            config.deps.libxslt.dev
          ];
        };
      };
      python-magic = {
        mkDerivation = {
          patches = [
            (config.deps.substituteAll {
              src = ./libmagic-path.patch;
              libmagic = "${config.deps.file}/lib/libmagic.so";
            })
          ];
        };
      };
    };
    flattenDependencies = true;
  };

  paths.lockFile = lib.mkForce "../lock.json";
}
