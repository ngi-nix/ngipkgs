{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
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
    makeWrapper ${python3.interpreter} $out/bin/0wm-ap-mock \
      --set-default "AP_MOCK_ADDRESS" "127.0.0.1" \
      --set-default "AP_MOCK_PORT" "8003" \
      --add-flags "server.py" \
      --add-flags '$AP_MOCK_PORT' \
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
