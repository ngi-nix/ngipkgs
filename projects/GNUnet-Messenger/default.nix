{pkgs, ...} @ args: {
  packages = {
    inherit (pkgs) gnunet-messenger-cli;
  };
}
