{
  fetchFromGitLab,
  buildPythonPackage,
}: let
  version = "2.1.2";
in
  buildPythonPackage {
    pname = "liberaforms-server";
    inherit version;

    src = fetchFromGitLab {
      owner = "liberaforms";
      repo = "server";
      rev = "v${version}";
      sha256 = "sha256-JNs7SU9imLzWeVFGx2gxqqt8Bbea7SsvoHXJBxxona4=";
    };
  }
