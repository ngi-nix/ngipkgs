{
  stdenv,
  nodejs,
  pnpm,
  lib,
  atomic-server,
}:
stdenv.mkDerivation rec {
  pname = "atomic-browser";
  inherit (atomic-server) version;
  src = "${atomic-server.src}/browser";

  pnpmDeps = pnpm.fetchDeps {
    inherit src pname;
    hash = "sha256-du+frFmNV1A4PE8iCRHETEqL0jVhtcxgOA+DhQnnRXg=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  postBuild = ''
    pnpm run build
  '';

  installPhase = ''
    runHook preInstall

    cp -R ./data-browser/dist/ $out/

    runHook postInstall
  '';

  meta = {
    description = "A GUI for viewing, editing and browsing Atomic Data";
    homepage = "https://github.com/atomicdata-dev/atomic-server/tree/develop/browser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
  };
}
