{
  stdenv,
  python3,
}:
stdenv.mkDerivation {
  name = "build-matrix";
  version = "unstable";
  propagatedBuildInputs = [
    (python3.withPackages (pythonPackages: [pythonPackages.networkx]))
  ];
  dontUnpack = true;
  installPhase = "install -Dm755 ${./build-matrix.py} $out/bin/build-matrix";
  meta.mainProgram = "build-matrix";
}
