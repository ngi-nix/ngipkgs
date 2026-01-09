{ ... }:

{
  services.dnsvizor = {
    enable = true;
    memory = 128;
    mainInterface = "enp1s0";
    settings = {
      hostname = "dnsvizor.mydomain.example";
      ipv4 = "10.0.0.2/24";
      ipv4-gateway = "10.0.0.1";
      ipv6 = "fdc9:281f:4d7:9ee9::2/64";
      ipv6-gateway = "fdc9:281f:4d7:9ee9::1";
      ca-seed = "Te9ffyY3Clcaz/4P7eFLyZQfLWIz/fSSK4NDb8THMDc=";
      password = "password";
      dns-block = [
        "block1.cli.example.com"
        "block2.cli.example.com"
      ];
      dns-blocklist-url = [
        "http://10.0.0.1/block-list-4"
        "http://[fdc9:281f:4d7:9ee9::1]:80/block-list-6"
        "https://example.com/non-existent-block-list"
      ];
      qname-minimisation = true;
      opportunistic-tls-authoritative = true;
    };
    openFirewall = true;
  };
}
