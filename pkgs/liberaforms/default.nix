{ stdenv, postgresql_11, fetchFromGitLab, fetchFromGitHub, pkgs, system, ... }:
let
  # Mach Nix is broken on recent Nixpkgs
  machNixpkgs = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "554d2d8aa25b6e583575459c297ec23750adb6cb";
    sha256 = "sha256-AXLDVMG+UaAGsGSpOtQHPIKB+IZ0KSd9WS77aanGzgc=";
  };

  machPkgs = import machNixpkgs { inherit system; };

  mach-nix = import (fetchFromGitHub {
    owner = "DavHau";
    repo = "mach-nix";
    rev = "3.5.0";
    sha256 = "sha256-j/XrVVistvM+Ua+0tNFvO5z83isL+LBgmBi9XppxuKA=";
  }) { pkgs = machPkgs; };

  liberaforms-src = fetchFromGitLab {
      owner = "liberaforms";
      repo = "liberaforms";
      rev = "v2.1.2";
      sha256 = "sha256-JNs7SU9imLzWeVFGx2gxqqt8Bbea7SsvoHXJBxxona4=";
  };

  liberaforms-env = let
    req = builtins.readFile "${liberaforms-src}/requirements.txt";
    #TODO lots of notes here; mach-nix doesnt handle (??xref various issues) range of cryptography package - because it doesnt support pyproject.toml?
    #I don't like this, but doing this is the fastest way to get the cryptography from nixpkgs, which is at 36.0.0 (mach-nix automatically finds it)
    filteredReq = builtins.replaceStrings ["cryptography==36.0.1"] ["cryptography==36.0.0"] req; # for liberaforms > v2.0.1
    # Needed for tests only; TODO upstream should make a dev-requirements.txt or whatever?
    # https://gitlab.com/liberaforms/liberaforms/-/commit/16c893ff539bfb6249b3b02f4c834eb8848c16d5
    extraReq = "factory_boy";
    requirements = ''
      ${filteredReq}
      ${extraReq}
    '';
  in
    mach-nix.mkPython {inherit requirements;};

in stdenv.mkDerivation {
    pname = "liberaforms";
    version = with builtins; let
      remove-newline = replaceStrings ["\n"] [""];
    in
    remove-newline (readFile "${liberaforms-src}/VERSION.txt");

    src = liberaforms-src;
    dontConfigure = true; # do not use ./configure

    propagatedBuildInputs = [ liberaforms-env postgresql_11]; #TODO unfuck

    installPhase = ''
      cp -r . $out
    '';

    #doCheck = true; #TODO why does this explicitly need to be set #NOTE: this is default false here then?, - and it's overridden to enabled in the flake check
    checkInputs = with liberaforms-env.passthru.pkgs; [pytest pytest-dotenv];

    passthru.test = ''
      source ${./test_env.sh.in}
      initPostgres $(mktemp -d)

      # Run pytest on the installed version. A running postgres database server is needed.
      (cd tests && cp test.ini.example test.ini && pytest -k "not test_save_smtp_config") #TODO why does this break?

      shutdownPostgres
    '';
}
