{ pkgs, fetchFromGitHub, ... }:
with (import ./pnpm2nix-lockfile-6.0 { inherit pkgs; });

mkPnpmPackage rec {
  version = "v0.34.5";

  prePatch = "exit 1";

  patches = [
    ./package-json-version.patch
  ];

  src = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-data-browser";
    rev = "9b913058508c9da6a4062fd0fe39fcefc1205c4d";
    hash = "sha256-lQDfFXnXCW+fhs1ayjbsm3VojxvMEh9eiUyHoTm3qtg=";
  };

}
