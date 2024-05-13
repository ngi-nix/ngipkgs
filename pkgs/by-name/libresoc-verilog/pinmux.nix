{
  stdenv,
  fetchFromLibresoc,
  python39,
}:
stdenv.mkDerivation rec {
  name = "libresoc-pinmux";
  version = "unstable-2024-03-31";

  src = fetchFromLibresoc {
    pname = "pinmux";
    rev = "ee6c6c5020f11e7debfd8262ffdb8abd6e1782c"; # HEAD @ version date
    hash = "sha256-Tux2RvcRmlpXMsHwve/+5rOyBRSThg9MVW2NGP3ZJxs=";
  };

  nativeBuildInputs = [python39];

  buildPhase = ''
    runHook preBuild
    python3.9 src/pinmux_generator.py -v -s ls180 -o ls180
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv ls180 $out
    runHook postInstall
  '';

  meta = {
    description = "This tools currently generates a BSV code which implements the pin-muxing logic between peripheral ports.";
    homepage = "https://git.libre-soc.org/?p=pinmux.git;a=summary";
  };
}
