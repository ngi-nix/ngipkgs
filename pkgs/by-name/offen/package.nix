{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "offen";
  version = "1.4.2-unstable-2026-02-14";

  src = fetchFromGitHub {
    owner = "offen";
    repo = "offen";
    rev = "03f5a90c07d04b7abc423cee4cb0dba5e59a7732";
    hash = "sha256-J3SvARFeOs/woSorYttVDyeeJM1FlsAVzpIL8UbP6nc=";
  };

  sourceRoot = "${finalAttrs.src.name}/server";

  vendorHash = "sha256-AeQa5oaOEB/50aPCRq702vMEtEctwP+jU5C6zB+3XR0=";

  meta = {
    description = "Offen Fair Web Analytics";
    homepage = "https://github.com/offen/offen";
    mainProgram = "offen";
    platforms = lib.platforms.all;
    license = with lib.licenses; [
      mit
      cc-by-nc-nd-40 # icon and logo
      asl20
    ];
    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
