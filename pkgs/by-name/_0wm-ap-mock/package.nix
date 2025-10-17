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
  version = "0-unstable-2025-10-27";

  src = fetchFromGitHub {
    owner = "lab0-cc";
    repo = "0WM-AP-Mock";
    rev = "dcc0d14826e56c02f0f538303c59115326dd8a47";
    hash = "sha256-ywii5ca6UIsHplLZf6jGBfbziTaoC8qbyvqJcChFTPc=";
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
