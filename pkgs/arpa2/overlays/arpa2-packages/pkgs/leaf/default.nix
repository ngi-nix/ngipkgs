{
  stdenv,
  helpers,
  quickder,
  lillydap,
  fetchFromGitLab,
}:
helpers.mkArpa2Derivation {
  pname = "leaf";
  version = "unstable-2020-04-28";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "leaf";
    rev = "b3861efce0ba143f6eb5451aac5be24f18e6d8ab";
    hash = "sha256-woEzlXyulVSpeJJQU0SsfC3U90cv3b9zzVh/w5iouJY=";
  };

  nativeBuildInputs = [quickder lillydap];
}
