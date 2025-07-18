{ pkgs, ... }:

{
  services.mox.enable = true;
  services.mox.hostname = "mail";
  services.mox.user = "admin@example.com";
  services.mox.openFirewall = true;
  services.mox.ports.http = 8090;
  services.mox.ports.https = 4443;
  services.mox.ports.smtp = 2525;

  environment.systemPackages = with pkgs; [
    mox
    unbound
    dig
  ];
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';

  networking.nameservers = [ "127.0.0.1" ];
  networking.hosts = {
    "127.0.0.1" = [
      "com."
      "mail.example.com"
      "example.com"
    ];
  };

  # Use unbound as a local DNS resolver and dissable DNSSEC validation
  # Listen only on the localhost interface both for IPv4 and IPv6
  # Define a local zone for com. to redirect queries to localhost and provide a static response
  # Define static DNS records
  services.unbound = {
    enable = true;
    resolveLocalQueries = true;
    enableRootTrustAnchor = false;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
        access-control = [
          "127.0.0.1/8 allow"
          "::1/128 allow"
        ];
      };
      local-zone = [
        "\"com.\" redirect"
      ];
      local-data = [
        "\"com. IN NS localhost\""
        "\"localhost. IN A 127.0.0.1\""
      ];
    };
  };
}
