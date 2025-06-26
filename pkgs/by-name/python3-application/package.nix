{
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.python3-application.overrideAttrs (oa: rec {
  version = "3.0.9";
  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "python3-application";
    tag = "release-${version}";
    hash = "sha256-79Uu9zaBIuuc+1O5Y7Vp4Qg2/aOrwvmdi5G/4AvL+T4=";
  };
})
