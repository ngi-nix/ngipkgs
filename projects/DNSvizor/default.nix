{
  lib,
  pkgs,
  sources,
  ...
}@args:

let
  problem =
    if lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.syslinux then
      null
    else
      {
        broken.reason = ''
          dependency pkgs.syslinux is not available on this platform
        '';
      };
  webInterfaceManual = {
    text = "Web interface manual";
    url = "https://robur-coop.github.io/dnsvizor-handbook/dnsvizor_web_interface.html";
  };
in
{
  metadata = {
    summary = "Privacy-enhanced, secure and robust DNS resolver and DHCP server with a small resource footprint as a MirageOS unikernel";
    subgrants = {
      Entrust = [ "DNSvizor" ];
    };
    links = {
      homepage = null;
      repo = {
        text = "Source repository";
        url = "https://github.com/robur-coop/dnsvizor";
      };
      docs = {
        text = "Handbook";
        url = "https://robur-coop.github.io/dnsvizor-handbook/";
      };
      blog = {
        text = "Blog";
        url = "https://blog.robur.coop/tags.html#tag-DNSvizor";
      };
      upstreamBuilds = {
        text = "Reproducible unikernel binaries built by upstream";
        url = "https://builds.robur.coop/job/dnsvizor";
      };
      mirageOS = {
        text = "MirageOS";
        url = "https://mirage.io/";
      };
    };
  };

  nixos.modules.services.dnsvizor = {
    name = "DNSvizor";
    module = ./services/dnsvizor/module.nix;
    examples = {
      "Enable DNSvizor as a stub DNS resolver" = {
        module = ./services/dnsvizor/examples/stub-dns-resolver.nix;
        description = ''
          Usage instructions

          1. Query DNS with UDP/TCP, DNS-over-TLS(DoT) and DNS-over-HTTPS(DoH)
          2. Open the web interface for management
        '';
        tests.stub-dns-resolver = {
          module = import ./services/dnsvizor/tests/dns.nix (args // { resolverKind = "stub"; });
          inherit problem;
        };
        links = { inherit webInterfaceManual; };
      };
      "Enable DNSvizor as a recursive DNS resolver" = {
        module = ./services/dnsvizor/examples/recursive-dns-resolver.nix;
        description = ''
          Usage instructions

          1. Query DNS with UDP/TCP, DNS-over-TLS(DoT) and DNS-over-HTTPS(DoH)
          2. Open the web interface for management
        '';
        tests.recursive-dns-resolver = {
          module = import ./services/dnsvizor/tests/dns.nix (args // { resolverKind = "recursive"; });
          inherit problem;
        };
        links = { inherit webInterfaceManual; };
      };
    };
  };

  nixos.demo.vm = {
    # no demo test since it is the same as the example test
    module = ./services/dnsvizor/examples/recursive-dns-resolver.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          FIXME Run `foobar` in the terminal
        '';
      }
      {
        instruction = ''
          FIXME Visit [http://127.0.0.1:8080](http://127.0.0.1:8080) in your browser
        '';
      }
    ];
    inherit problem;
    links = { inherit webInterfaceManual; };
  };
}
