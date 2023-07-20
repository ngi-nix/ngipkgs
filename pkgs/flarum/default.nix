{ stdenv, fetchFromGitHub, php, phpPackages, ...  }:

stdenv.mkDerivation rec {
  pname = "flarum";
  version = "v1.8.1";
  src = fetchFromGitHub {
    owner = "flarum";
    repo = "framework";
    rev = version;
  };

  buildInputs = [php phpPackages.composer];

  buildPhase = ''
    composer install
  '';

  installPhase = ''
    mkdir -p $out/www
    cp -r * $out/www
  '';
}

