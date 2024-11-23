{pkgs, ...} @ args: {
  packages = {
    inherit (pkgs) wireguard-rs;
  };
}
