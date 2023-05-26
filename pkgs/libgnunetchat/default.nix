{ stdenv, gnunet, libsodium, libgcrypt, libextractor, fetchgit }:

# From https://github.com/ngi-nix/gnunet-messenger-cli/blob/main/flake.nix
stdenv.mkDerivation {
  name = "libgnunetchat";
  src = fetchgit {
    url = "https://git.gnunet.org/libgnunetchat";
    rev = "a67bafd0a50710de5fd729dbc5b938ad48580954";
    sha256 = "sha256-U6m6AgjnYy9BL158WktpGbf/Evurst5LExK4YU26WJU=";
  };

  buildInputs = [ gnunet libsodium libgcrypt libextractor ];

  INSTALL_DIR = (placeholder "out") + "/";
  prePatch = ''
    mkdir -p $out/lib
  '';
}
