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
  version = "0-unstable-2025-10-06";

  src = fetchFromGitHub {
    owner = "lab0-cc";
    repo = "0WM-Client";
    rev = "3f06bd666c67af7f36dc2363617af33f6a4af3ea";
    hash = "sha256-5ZlQHAeUwoA/7DhhQBBH/PLkDFG+jeHWy4I8ophGRW4=";
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
    makeWrapper ${lib.getExe serve} $out/bin/0wm-client \
      --prefix PATH : ${lib.makeBinPath [ xsel ]} \
      --add-flags "--symlinks" \
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
