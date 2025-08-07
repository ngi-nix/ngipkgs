{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  name = "ntpd-rs-nts";

  nodes.node.imports = [
    sources.modules.ngipkgs
    sources.modules.services.ntpd-rs
    ../examples/nts.nix
  ];

  testScript = ''
    start_all()

    node.wait_for_unit('multi-user.target')
    node.succeed('systemctl is-active ntpd-rs.service')
    node.fail('systemctl is-active ntpd-rs-metrics.service')

    node.succeed("grep 'time.system76.com' $(systemctl status ntpd-rs | grep -oE '/nix/store[^ ]*ntpd-rs.toml')")
    node.succeed("grep '^mode = \"nts\"'   $(systemctl status ntpd-rs | grep -oE '/nix/store[^ ]*ntpd-rs.toml')")
  '';
}
