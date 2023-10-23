{
  stdenv,
  helpers,
  quickder,
  gperf,
  fetchFromGitLab,
}:
helpers.mkArpa2Derivation rec {
  pname = "lillydap";
  version = "0.9.2";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "lillydap";
    rev = "v${version}";
    hash = "sha256-L2zmitXezGzDZXLDxohU3DTuHE18KUZEMg98ui2AF+c=";
  };

  nativeBuildInputs = [quickder gperf];
}
