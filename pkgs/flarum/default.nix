{ pkgs }:

rec {
  pname = "flarum";
  version = "v1.8.0";
  src = builtins.fetchFromGitHub {
    owner = "flarum";
    repo = "flarum";
    rev = version;
    sha256 = "";
  };

  dependencies = pkgs.lib.makeOverridable (import ./dependencies) {
    inherit pkgs;
    noDev = true;
  };
}
