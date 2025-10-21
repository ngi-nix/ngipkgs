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
  pname = "0wm-client";
  version = "0-unstable-2025-10-16";

  src = fetchFromGitHub {
    owner = "lab0-cc";
    repo = "0WM-Client";
    rev = "b3dcf654da9fd12087eff37bc24844fc279108ea";
    hash = "sha256-ssCsSqzckJoHl80bBrjx0T4PF4Fc01F85KtsqPykr0I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  postConfigure = ''
    substituteInPlace js/app.mjs \
      --replace-fail 'http://ap.local' 'http://127.0.0.1:8003'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r * $out

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${lib.getExe serve} $out/bin/0wm-client \
      --prefix PATH : ${lib.makeBinPath [ xsel ]} \
      --add-flags "--symlinks" \
      --set-default "CLIENT_ADDRESS" "127.0.0.1" \
      --set-default "CLIENT_PORT" "8002" \
      --add-flags '-l "tcp://$CLIENT_ADDRESS:$CLIENT_PORT"' \
      --chdir $out
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "0WM mobile client frontend";
    homepage = "https://github.com/lab0-cc/0WM-Client";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
    mainProgram = "0wm-client";
  };
})
