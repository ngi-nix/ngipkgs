{
  callPackage,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_8,
  lib,
  nodePackages,
}:
stdenv.mkDerivation rec {
  pname = "atomic-browser";
  version = "v0.37.0";

  monorepoSrc = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-server";
    rev = "v0.37.0";
    hash = "sha256-+Lk2MvkTj+B+G6cNbWAbPrN5ECiyMJ4HSiiLzBLd74g=";
  };

  src = "${monorepoSrc}/browser";
  pnpmDeps = pnpm_8.fetchDeps {
    inherit src pname;
    hash = "sha256-sXXEgMBKImeGIYrFw17Uie6qTylKrJ9MNm8WJFRAi1A=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_8.configHook
  ];

  postBuild = ''
    pnpm run build
  '';

  installPhase = ''
    cp -R ./data-browser/dist/ $out/
  '';

  meta = {
    description = "Create, share, fetch and model linked Atomic Data! There are three components: a javascript / typescript library, a react library, and a complete GUI: Atomic-Data Browser.";
    homepage = "https://github.com/atomicdata-dev/atomic-server/tree/develop/browser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
  };
}
