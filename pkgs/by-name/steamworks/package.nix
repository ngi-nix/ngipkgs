{
  stdenv,
  lib,
  cmake,
  arpa2cm,
  arpa2common,
  openldap,
  flex,
  bison,
  sqlite,
  catch2,
  log4cpp,
  fetchFromGitLab,
}: let
  inherit
    (lib)
    licenses
    platforms
    ;
in
  stdenv.mkDerivation rec {
    pname = "steamworks";
    version = "0.97.2";

    src = fetchFromGitLab {
      owner = "arpa2";
      repo = "steamworks";
      rev = "v${version}";
      hash = "sha256-hD1nTyv/t7MQdopqivfSE0o4Qk1ymG8zQVg56lY+t9o=";
    };

    # src/common/logger.h:254:63: error: 'uint8_t' does not name a type
    postPatch = ''
      sed -i "38i #include <cstdint>" src/common/logger.h
    '';

    nativeBuildInputs = [cmake arpa2cm arpa2common];

    buildInputs = [
      openldap
      flex
      bison
      sqlite
      #catch2 # Currently makes the CMakeFile generate a wrong linker path
      log4cpp
    ];

    # Currently doesn't build in `Release` since a macro is messing with some code
    # when building in `Release`.
    cmakeBuildType = "Debug";

    meta = {
      description = "Configuration information distributed over LDAP in near realtime";
      homepage = "https://gitlab.com/arpa2/steamworks";
      license = licenses.bsd2;
      maintainers = [];
      platforms = platforms.linux;
    };
  }
