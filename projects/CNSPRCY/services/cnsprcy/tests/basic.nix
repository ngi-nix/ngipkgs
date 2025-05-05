{
  sources,
  ...
}:
{
  name = "cnsprcy-server";

  nodes = {
    machine1 =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.cnsprcy
          sources.examples.CNSPRCY.basic
        ];
        networking.firewall.enable = false;
      };
    machine2 =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.cnsprcy
          sources.examples.CNSPRCY.basic
        ];
        networking.firewall.enable = false;
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine1.wait_for_unit("cnsprcy.service")
      machine2.wait_for_unit("cnsprcy.service")

      machine1.succeed("su cnsprcy -c 'cnspr interface add 192.168.1.1:3030'")
      machine2.succeed("su cnsprcy -c 'cnspr interface add 192.168.1.2:3030'")

      pubkey = machine1.succeed("su cnsprcy -c 'cnspr manage advertise'").split()[-1]
      invitation = machine2.succeed("su cnsprcy -c 'cnspr manage invite {}'".format(pubkey)).split()[-1]
      machine1.succeed("su cnsprcy -c 'cnspr manage accept {}'".format(invitation))
    '';
}
