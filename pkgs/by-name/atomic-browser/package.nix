{
  fetchFromGitHub,
  lib,
  mkPnpmPackage,
}: let
  inherit
    (lib)
    licenses
    maintainers
    ;
in
mkPnpmPackage rec {
  pname = "atomic-browser";
  version = "v0.37.0";

  monorepoSrc = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-server";
    rev = "v0.37.0";
    hash = "sha256-+Lk2MvkTj+B+G6cNbWAbPrN5ECiyMJ4HSiiLzBLd74g=";
  };

  src = "${monorepoSrc}/browser";

  # These 2 options are needed to work with pnpm workspaces, which atomic-browser is using
  # https://github.com/nzbr/pnpm2nix-nzbr/issues/29#issuecomment-1918811838
  installInPlace = true;
  distDir = ".";

  meta = {
    description = "Create, share, fetch and model linked Atomic Data! There are three components: a javascript / typescript library, a react library, and a complete GUI: Atomic-Data Browser.";
    homepage = "https://github.com/atomicdata-dev/atomic-server/tree/develop/browser";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
