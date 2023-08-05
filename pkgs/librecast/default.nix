{
  stdenv,
  pkgs,
  fetchFromGitea,
  lcrq,
  ...
}:
stdenv.mkDerivation rec {
  name = "librecast";
  version = "0.6.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "librecast";
    repo = "librecast";
    rev = "v${version}";
    sha256 = "sha256-o7ZPczQOw45kAAyu0fHCTKTUC78W0gkuL2Qge0+1Pc4=";
  };
  buildInputs = [lcrq pkgs.libsodium];
  installFlags = ["PREFIX=$(out)"];
}
