{ src, pname, version, stdenv, lib, cmake }:

stdenv.mkDerivation {
  inherit src pname version;

  nativeBuildInputs = [ cmake ];

  doCheck = true;

  meta = with lib; {
    description = "CMake module library for ARPA2";
    homepage = "https://gitlab.com/arpa2/arpa2cm";
    license = licenses.bsd2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
