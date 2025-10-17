{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  serve,
  xsel,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "0wm-ap-mock";
  version = "0-unstable-2025-08-17";

  src = fetchFromGitHub {
    owner = "lab0-cc";
    repo = "0WM-AP-Mock";
    rev = "ee095e56d83e706be5add1a163923c2db6411e5d";
    hash = "sha256-ce1mLiHFT1LF0fUI1zl4AhXCFhmcoaWo9O6kozDVENM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r * $out

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${lib.getExe serve} $out/bin/0wm-ap-mock \
      --prefix PATH : ${lib.makeBinPath [ xsel ]} \
      --add-flags "--symlinks" \
      --chdir $out
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Mock Zyxel AP server";
    homepage = "https://github.com/lab0-cc/0WM-AP-Mock";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
    mainProgram = "0wm-ap-mock";
  };
})
