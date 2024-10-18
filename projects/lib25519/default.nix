{pkgs, ...} @ args: {
  packages = {inherit (pkgs) lib25519;};
}
