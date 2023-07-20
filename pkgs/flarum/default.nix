{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "flarum";
  version = "v1.8.1";
  src = fetchFromGitHub {
    owner = "flarum";
    repo = "framework";
    rev = version;
  };
}

