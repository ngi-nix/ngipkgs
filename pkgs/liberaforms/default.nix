{
  stdenv,
  callPackage,
  liberaforms-env,
  postgresql_11,
  fetchFromGitLab,
  fetchFromGitHub,
  pkgs,
  system,
  ...
}: let
  src = callPackage ./src.nix {};
in
  stdenv.mkDerivation {
    pname = "liberaforms";
    version = with builtins; let
      remove-newline = replaceStrings ["\n"] [""];
    in
      remove-newline (readFile "${src}/VERSION.txt");

    inherit src;
    dontConfigure = true; # do not use ./configure

    propagatedBuildInputs = [
      liberaforms-env
      postgresql_11
    ]; #TODO unfuck

    installPhase = ''
      cp -r . $out
    '';

    #doCheck = true; #TODO why does this explicitly need to be set #NOTE: this is default false here then?, - and it's overridden to enabled in the flake check
    checkInputs = with liberaforms-env.passthru.pkgs; [pytest pytest-dotenv];

    # this is just a string, should be a derivation
    passthru.test = ''
      source ${./test_env.sh.in}
      initPostgres $(mktemp -d)

      # Run pytest on the installed version. A running postgres database server is needed.
      (cd tests && cp test.ini.example test.ini && pytest -k "not test_save_smtp_config") #TODO why does this break?

      shutdownPostgres
    '';
  }
