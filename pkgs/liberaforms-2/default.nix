{}: {
  pname = "liberaforms-server";
  version = "";

  src = {
  };

  {fetchFromGitLab, ...}:
fetchFromGitLab {
  owner = "liberaforms";
  repo = "liberaforms";
  rev = "v2.1.2";
  sha256 = "sha256-JNs7SU9imLzWeVFGx2gxqqt8Bbea7SsvoHXJBxxona4=";
}

}
