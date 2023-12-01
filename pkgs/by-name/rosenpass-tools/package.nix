{
  lib,
  stdenv,
  makeWrapper,
  installShellFiles,
  coreutils,
  findutils,
  gawk,
  rosenpass,
  wireguard-tools,
}: let
  inherit
    (lib)
    makeBinPath
    ;
in
  stdenv.mkDerivation {
    inherit (rosenpass) version src;
    pname = "rosenpass-tools";

    nativeBuildInputs = [makeWrapper installShellFiles];

    postInstall = ''
      install -D $src/rp $out/bin/rp
      installManPage $src/doc/rp.1
      wrapProgram $out/bin/rp \
        --prefix PATH : ${makeBinPath [
        coreutils
        findutils
        gawk
        rosenpass
        wireguard-tools
      ]}
    '';

    meta =
      rosenpass.meta
      // {
        description = "This package contains the Rosenpass tool `rp`, which is a script that wraps the `rosenpass` binary.";
        mainProgram = "rp";
      };
  }
