{
  lib,
  stdenv,
  coreutils,
  findutils,
  gawk,
  makeWrapper,
  rosenpass,
  wireguard-tools,
}:
stdenv.mkDerivation {
  pname = "rosenpass-tools";
  inherit (rosenpass) version src;

  nativeBuildInputs = [makeWrapper];

  postInstall = let
    rpDependencies = [rosenpass wireguard-tools coreutils findutils gawk];
  in ''
    install -D $src/rp $out/bin/rp
    wrapProgram $out/bin/rp --prefix PATH : ${lib.makeBinPath rpDependencies}
  '';

  meta = {
    inherit (rosenpass.meta) homepage license maintainers;
    description = rosenpass.meta.description + " This is a wrapper script around the `rosenpass` Rust binary.";
  };
}
