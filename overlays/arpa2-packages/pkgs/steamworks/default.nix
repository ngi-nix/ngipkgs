{ src, pname, version, stdenv, lib, helpers, openldap, flex, bison, sqlite
, catch2, log4cpp }:

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

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out
  '';

  NIX_CFLAGS_COMPILE = "-pthread";

  meta = with lib; {
    description =
      "Configuration information distributed over LDAP in near realtime";
    homepage = "https://gitlab.com/arpa2/steamworks";
    license = licenses.bsd2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
