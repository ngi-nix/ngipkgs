{
  fetchgit,
  lib,
  jq,
  nodejs_18,
  python3,
  zip,
  callPackage,
  mkPnpmPackage,
}: let
  pname = "wallet-core";
  version = "0.9.3";

  patches = [
    ./no-git-bootstrap.patch
    ./fix-broken-esbuild.patch
  ];

  src = fetchgit {
    url = "https://git.taler.net/wallet-core.git";
    rev = "v${version}";
    hash = "sha256-9skF2jPkODnREFM9FOMroCjlkbVQ2V9SfiqGvhUbgvc=";
    fetchSubmodules = true;
    leaveDotGit = true; # Required for correct submodule fetching
    # Delete .git folder for reproducibility (otherwise, the hash changes unexpectedly after fetching submodules)
    postFetch = ''
      (
        cd $out
        rm -rf .git
      )
    '';
  };

  nodejs = nodejs_18;
in
mkPnpmPackage {
  inherit nodejs patches pname src version;

  pnpm = nodejs.pkgs.pnpm;

  # This is the lockfile with './fix-broken-esbuild.patch' applied
  # mkPnpmPackage does not apply the patch even if we pass the patches.
  pnpmLockYaml = ./. + "/pnpm-lock.yaml";

  script = "compile --offline";
}
