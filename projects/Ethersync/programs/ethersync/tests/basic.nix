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
          sources.examples.Ethersync."Using Ethersync"
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
      peer = "12D3KooWMX6EYnLXfWs3vsGhtWgqBfRSoWqs4GiDMu3rB4qSjRpX";
    in
    ''
      import time

      start_all()

      server.wait_for_unit("default.target")
      # enable ethersync for the directory
      server.send_chars("mkdir -p .ethersync\n")
      server.send_chars("echo ${key} | base64 -d >.ethersync/key\n")
      server.send_chars("chmod 600 .ethersync/key\n")
      server.send_chars("echo server >file.txt\n")
      server.screenshot("server-prepare.png")
      server.send_chars("ethersync daemon --port 4242 >/dev/null &\n")
      server.wait_for_open_port(4242)
      server.screenshot("server-ready.png")

      client.wait_for_unit("default.target")
      # enable ethersync for the directory
      client.send_chars("mkdir -p .ethersync\n")
      client.screenshot("client-prepare.png")
      client.send_chars("ethersync daemon --peer /ip4/192.168.1.1/tcp/4242/p2p/${peer} >/dev/null 2>&1 &\n")
      client.wait_until_succeeds("test -s /root/file.txt")
      client.screenshot("client-ready.png")

      client.send_chars("nvim file.txt\n")
      time.sleep(1)
      client.send_chars("dd")
      client.send_chars("iclient")
      client.send_key("esc")
      time.sleep(1)
      client.screenshot("client-editing.png")
      client.send_chars(":wq\n")

      server.wait_until_succeeds("test $(cat ~/file.txt) = client")
    '';
}
