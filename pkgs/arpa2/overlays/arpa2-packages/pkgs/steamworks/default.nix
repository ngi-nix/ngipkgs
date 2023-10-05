{
  src,
  pname,
  version,
  stdenv,
  lib,
  helpers,
  openldap,
  flex,
  bison,
  sqlite,
  catch2,
  log4cpp,
}:
helpers.mkArpa2Derivation {
  inherit src pname version;

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

  meta = with lib; {
    description = "Configuration information distributed over LDAP in near realtime";
    homepage = "https://gitlab.com/arpa2/steamworks";
    license = licenses.bsd2;
    maintainers = [];
    platforms = platforms.linux;
  };
}
