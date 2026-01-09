{ ... }:

{
  services.dnsvizor = {
    enable = true;
    memory = 128;
    mainInterface = "enp1s0";
    settings = {
      ipv4 = "10.0.0.2/24";
      ipv4-gateway = "10.0.0.1";
      ipv4-only = "true";
      ca-seed = "Te9ffyY3Clcaz/4P7eFLyZQfLWIz/fSSK4NDb8THMDc=";
      password = "password";
      dns-block = [
        "block1.cli.example.com"
        "block2.cli.example.com"
      ];
      dns-blocklist-url = [
        "http://10.0.0.1/block-list"
        "https://example.com/non-existent-block-list"
      ];
      dns-upstream = "tls:1.1.1.1";
    };
  };
}
