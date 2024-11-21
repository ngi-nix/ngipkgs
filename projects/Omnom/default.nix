{pkgs, ...}: {
  packages = {inherit (pkgs) omnom;};
  # https://github.com/asciimoo/omnom/blob/master/config/config.go
  nixos.services = null;
  nixos.tests = null;
  nixos.examples = null;
}
