# This test starts two machines, one as the server and another as the client.
# The server will create a file with initial content.  Then the client will
# try to connect and verify that the contents are in sync.  After that it
# will try to edit the file.  Finally we check if the server has received the
# changes.

{
  sources,
  lib,
  ...
}:

{
  name = "Ethersync";

  nodes =
    let
      config = {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.ethersync
          sources.examples.Ethersync."Enable Ethersync"
        ];
        services.getty.autologinUser = "root";
      };
    in
    {
      server = config // {
        networking.firewall.allowedTCPPorts = [ 4242 ];
        networking.interfaces.eth1.ipv4.addresses = lib.mkForce [
          {
            address = "192.168.1.1";
            prefixLength = 24;
          }
        ];
      };
      client = config // {
        networking.interfaces.eth1.ipv4.addresses = lib.mkForce [
          {
            address = "192.168.1.2";
            prefixLength = 24;
          }
        ];
      };
    };

  testScript =
    let
      key = "CAESQGurlr9XTdGuz2nXI6esucINWpDoLBIW2qlYhOKGrggLrd9aLlCdAp1iQE6ZEMzFFVv5KQXp7sTB+YhllBZ/NgQ=";
      secret-address = "320e79a691e6f605c04d3579bac1870947898658bd27e8d4ceb60f80bf0fefc2#86ae080baddf5a2e509d029d62404e9910ccc5155bf92905e9eec4c1f9886594";
    in
    ''
      import time

      start_all()

      server.wait_for_unit("default.target")
      # enable ethersync for the directory
      server.succeed("mkdir -p .ethersync")
      server.succeed("echo ${key} | base64 -d >.ethersync/key")
      server.succeed("chmod go-rwx .ethersync")
      server.succeed("chmod 600 .ethersync/key")
      server.succeed("echo server >file.txt")
      server.execute("ethersync share >/dev/null &")

      client.wait_for_unit("default.target")
      # enable ethersync for the directory
      client.send_chars("mkdir -p .ethersync\n")
      client.send_chars("chmod go-rwx .ethersync\n")
      client.send_chars("echo peer=${secret-address} >.ethersync/config\n")
      client.send_chars("ethersync join >/dev/null 2>&1 &\n")
      client.wait_until_succeeds("test -s /root/file.txt")

      client.send_chars("nvim file.txt\n")
      time.sleep(1)
      client.send_chars("dd")
      client.send_chars("iclient")
      client.send_key("esc")
      time.sleep(1)
      client.send_chars(":wq\n")

      server.wait_until_succeeds("test $(cat /tmp/file.txt) = client")
    '';
}
