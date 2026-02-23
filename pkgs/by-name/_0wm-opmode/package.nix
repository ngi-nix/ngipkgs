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
  pname = "0wm-opmode";
  version = "0-unstable-2026-02-09";

  src = fetchFromGitHub {
    owner = "lab0-cc";
    repo = "0WM-OpMode";
    rev = "365dce706ec01627412e72f57e650fe84a3ddf02";
    hash = "sha256-0ke6dT/u9oD7HGR2z3nQiZ8MtPla2mhWjHPDOkP9u6Y=";
    fetchSubmodules = true;
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
    makeWrapper ${lib.getExe serve} $out/bin/0wm-opmode \
      --prefix PATH : ${lib.makeBinPath [ xsel ]} \
      --add-flags "--symlinks" \
      --set-default "OP_MODE_ADDRESS" "127.0.0.1" \
      --set-default "OP_MODE_PORT" "8001" \
      --add-flags '-l "tcp://$OP_MODE_ADDRESS:$OP_MODE_PORT"' \
      --chdir $out
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "0WM operator frontend";
    homepage = "https://github.com/lab0-cc/0WM-OpMode";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
    mainProgram = "0wm-opmode";
  };
})
