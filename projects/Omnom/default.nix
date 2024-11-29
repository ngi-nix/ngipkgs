{pkgs, ...}: {
  packages = {inherit (pkgs) omnom;};
  nixos = {
    # https://github.com/asciimoo/omnom/blob/master/config/config.go
    modules.services = null;
    tests = null;
    examples = null;
  };
}
