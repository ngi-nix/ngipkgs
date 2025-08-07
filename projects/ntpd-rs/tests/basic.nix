{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  name = "ntpd-rs-basic";

  nodes.node.imports = [
    sources.modules.ngipkgs
    sources.modules.services.ntpd-rs
    sources.examples.ntpd-rs."Replace the default `timesyncd` service with `ntpd-rs`"
  ];

  testScript = ''
    start_all()

    node.wait_for_unit('multi-user.target')
    node.succeed('systemctl is-active ntpd-rs.service')
    node.fail('systemctl is-active ntpd-rs-metrics.service')

    node.succeed("grep 'time.cloudflare.com' $(systemctl status ntpd-rs | grep -oE '/nix/store[^ ]*ntpd-rs.toml')")
    node.succeed("grep '^mode = \"server\"'  $(systemctl status ntpd-rs | grep -oE '/nix/store[^ ]*ntpd-rs.toml')")
  '';
}
