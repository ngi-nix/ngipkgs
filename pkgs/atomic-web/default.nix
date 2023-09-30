{ pkgs, fetchFromGitHub, ... }:
with (import ./pnpm2nix-lockfile-6.0 { inherit pkgs; });

mkPnpmPackage rec {
  version = "v0.34.5";

  src = fetchFromGitHub {
    # https://github.com/atomicdata-dev/atomic-server.git
    owner = "atomicdata-dev";
    repo = "atomic-server";
    rev = version;
    hash = "sha256-rqucTVvlXe9CXPsZ2cNzyDK9onXw/H96PzWpTR7Fdl4=";
  };

  sourceRoot = "${src}/browser";
}
