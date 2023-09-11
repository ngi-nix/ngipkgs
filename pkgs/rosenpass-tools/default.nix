{
  lib,
  makeWrapper,
  stdenv,
  coreutils,
  findutils,
  gawk,
  rosenpass,
  wireguard-tools,
}:
stdenv.mkDerivation {
  pname = "rosenpass-tools";
  inherit (rosenpass) version src;

  nativeBuildInputs = [makeWrapper];

  postInstall = let
    rpDependencies = [
      coreutils
      findutils
      gawk
      rosenpass
      wireguard-tools
    ];
  in ''
    install -D $src/rp $out/bin/rp
    wrapProgram $out/bin/rp --prefix PATH : ${lib.makeBinPath rpDependencies}

    install -D doc/rp.1 $out/share/man/man1/rp.1
  '';

  meta = {
    inherit (rosenpass.meta) homepage license maintainers;
    description = rosenpass.meta.description + " This is a wrapper script around the `rosenpass` Rust binary.";
  };
}
