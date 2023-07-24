{ pkgs }:

{
  src = builtins.fetchFromGitHub {
    owner = "flarum";
    repo = "flarum";
    rev = "v1.8.0";
    sha256 = "";
  };

  dependencies = pkgs.lib.makeOverridable (import ./dependencies) {
    inherit pkgs;
    noDev = true;
  };
}
