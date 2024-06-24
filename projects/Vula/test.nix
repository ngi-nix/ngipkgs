{
  sources,
  lib,
  ...
}: let
  inherit (lib) recursiveUpdate mkForce;
in {
  name = "vula";

  nodes.a = {
    imports = [
      sources.modules.default
      sources.modules."services.vula"
    ];

    services.vula.enable = true;
    services.vula.openFirewall = true;

    services.vula.logLevel = "DEBUG";

    # Make sure that if hosts can resolve each others' names,
    # it is thanks to vula and the nss module it uses.
    networking.extraHosts = mkForce "";

    services.vula.userPrefix = "non-default-prefix";
    services.vula.systemGroup = "non-default-system-group";
    services.vula.operatorsGroup = "vula-managers";
    users.users.user.isNormalUser = true;
    users.users.admin.isNormalUser = true;
    users.users.admin.extraGroups = ["vula-managers"];
  };

  nodes.b.imports = [
    sources.modules.default
    sources.modules."services.vula"
    ./example-simple.nix
  ];

  testScript = ''
    start_all()
    a.wait_for_unit("vula-organize.service")
    a.wait_for_unit("vula-publish.service")
    a.wait_for_unit("vula-discover.service")
    b.wait_for_unit("vula-organize.service")
    b.wait_for_unit("vula-publish.service")
    b.wait_for_unit("vula-discover.service")

    def test_peer(node):
        peer = 'a.local.' if node.name == 'b' else 'b.local.'
        node.wait_until_succeeds(f"ping -I vula -c 1 {peer}", timeout=60)

        peer_ip = node.succeed(f"getent hosts {peer}").split()[0]
        route_result = node.succeed(f"ip route get {peer_ip}")
        assert " dev vula " in route_result

    test_peer(a)
    test_peer(b)

    a.succeed("pgrep --uid non-default-prefix-organize vula")
    a.succeed("pgrep --uid non-default-prefix-discover vula")
    a.succeed("pgrep --uid non-default-prefix-publish vula")

    group_count = a.succeed("pgrep --count --group non-default-system-group vula").strip()
    assert group_count == "3", "vula process group count should be 3"

    # log level
    a.succeed("pgrep --full -- 'vula.* --verbose organize'")
    a.succeed("pgrep --full -- 'vula.* --verbose discover'")
    a.succeed("pgrep --full -- 'vula.* --verbose publish'")

    a.fail("su - user -c 'vula status'")
    a.succeed("su - admin -c 'vula status'")

    a.fail("su - user -c 'vula peer'")
    a.succeed("su - admin -c 'vula peer'")

    a.fail("su - user -c 'vula prefs set pin_new_peers true'")
    a.succeed("su - admin -c 'vula prefs set pin_new_peers true'")
  '';

  interactive.nodes.b = {
    virtualisation.memorySize = 4096;
    virtualisation.cores = 3;
    users.users.joe.isNormalUser = true;
    users.users.joe.password = "";
    users.users.admin.isNormalUser = true;
    users.users.admin.extraGroups = ["vula-ops"];
    users.users.admin.password = "";
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.xfce.enable = true;
    };
  };
}
