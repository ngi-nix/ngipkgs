{ src, pname, version, stdenv, lib, cmake, arpa2cm, ragel, lmdb, libressl
, libsodium, pkgconfig, libkrb5, e2fsprogs, doxygen, graphviz }:

stdenv.mkDerivation rec {
  inherit src pname version;

  nativeBuildInputs = [ cmake arpa2cm ];

  buildInputs = [
    ragel
    lmdb
    libressl
    libsodium
    pkgconfig
    libkrb5
    e2fsprogs
    doxygen
    graphviz
  ];

  propagatedBuildInputs = buildInputs;

  # The project uses single argument `printf` throughout the program
  # Disabling this seems like the easiest fix
  hardeningDisable = [ "format" ];

  meta = with lib; {
    description =
      "ARPA2 ID and ACL libraries and other core data structures for ARPA2";
    longDescription = ''
      The ARPA2 Common Library package offers elementary services that can
      benefit many software packages.  They are designed to be easy to
      include, with a minimum of dependencies.  At the same time, they were
      designed with the InternetWide Architecture in mind, thus helping to
      liberate users.'';
    homepage = "https://gitlab.com/arpa2/arpa2common";
    license = with licenses; [ bsd2 cc-by-sa-40 cc0 isc ];
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
