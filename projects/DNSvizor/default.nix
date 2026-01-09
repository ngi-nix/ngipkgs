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
    examples =
      let
        mkExample =
          {
            exampleName,
            exampleModule,
            exampleDescription,
            testName,
            testModule,
            testCfg,
          }:
          lib.nameValuePair exampleName {
            module = exampleModule;
            description = exampleDescription;
            tests =
              let
                testArgToString =
                  testArgName: testArgValue: seperator:
                  if testArgValue == true then
                    seperator + testArgName
                  else if testArgValue == false then
                    ""
                  else if lib.isString testArgValue then
                    seperator + testArgValue
                  else
                    throw "testArgToString: not implemented for ${testArgName}=${toString testArgValue}";
                testArgsToString =
                  testArgs:
                  lib.pipe testArgs [
                    (lib.mapAttrs (testArgName: testArgValue: "${testArgToString testArgName testArgValue "-"}"))
                    lib.attrValues
                    lib.concatStrings
                  ];
                mkTest =
                  testArgs:
                  lib.nameValuePair ("${testName}${testArgsToString testArgs}") {
                    module = import testModule (args // testArgs // { inherit exampleName; });
                    inherit problem;
                  };
              in
              lib.listToAttrs (map mkTest (lib.cartesianProduct testCfg));
            links = { inherit webInterfaceManual; };
          };
        dnsResolverExampleDescription = ''
          Usage instructions

          1. Query DNS with UDP/TCP, DNS-over-TLS(DoT) and DNS-over-HTTPS(DoH)
          2. Open the web interface for management
        '';
      in
      lib.listToAttrs (
        map mkExample [
          {
            exampleName = "Enable DNSvizor as a IPv4-only stub DNS resolver";
            exampleModule = ./services/dnsvizor/examples/stub-dns-resolver.nix;
            exampleDescription = dnsResolverExampleDescription;
            testName = "dns-ipv4";
            testModule = ./services/dnsvizor/tests/dns.nix;
            testCfg = {
              resolverKind = [ "stub" ];
              useNetworkd = [
                true
                false
              ];
              useNftables = [
                true
                false
              ];
            };
          }
          {
            exampleName = "Enable DNSvizor as a dual-stack recursive DNS resolver";
            exampleModule = ./services/dnsvizor/examples/recursive-dns-resolver.nix;
            exampleDescription = dnsResolverExampleDescription;
            testName = "dns-dualstack";
            testModule = ./services/dnsvizor/tests/dns.nix;
            testCfg = {
              resolverKind = [ "recursive" ];
              useNetworkd = [
                true
                false
              ];
              useNftables = [
                true
                false
              ];
            };
          }
        ]
      );
  };

  nixos.demo.vm = {
    module = ./services/dnsvizor/examples/recursive-dns-resolver.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Visit <https://127.0.0.1:4443> in your browser.  This is a web interface of DNSvizor.

          You'll see a warning of potential security risk.
          Rest assured.
          This is because DNSvizor uses a self-signed certification.

          Accept the risk and continue.
        '';
      }
      {
        instruction = ''
          In the demo VM terminal, run this to send DNS queries to DNSvizor (`10.0.0.2`):

          ```shellSession
          $ q --verbose www.example.com A @10.0.0.2
          ```

          If the query timeouts, re-run the command to query again.
        '';
      }
      {
        instruction = ''
          You can also use an IPv6 address for DNSvizor (`fdc9:281f:4d7:9ee9::2`):

          ```shellSession
          $ q --verbose www.example.com A @fdc9:281f:4d7:9ee9::2
          ```
        '';
      }
      {
        instruction = ''
          You can also use a domain name for DNSvizor (`dnsvizor.mydomain.example`):

          ```shellSession
          $ q --verbose www.example.com A @dnsvizor.mydomain.example
          ```
        '';
      }
      {
        instruction = ''
          Send encrypted DNS queries using `DNS-over-TLS`:

          ```shellSession
          $ q --verbose www.example.com A @tls://dnsvizor.mydomain.example
          ```

          You'll see an error telling you that certification verification failed.
          This is because DNSvizor uses a self-signed certification, which is not trusted by default.
          You can ignore that error by adding `--tls-insecure-skip-verify`:

          ```shellSession
          $ q --verbose --tls-insecure-skip-verify www.example.com A @tls://dnsvizor.mydomain.example
          ```
        '';
      }
      {
        instruction = ''
          Let's show you how to trust that self-signed certification of DNSvizor.

          First, we extract that certification using `curl`.

          ```shellSession
          $ curl --write-out %{certs} https://dnsvizor.mydomain.example > /tmp/self-signed-cert.pem
          ```

          Then we setting environment variable `SSL_CERT_FILE` before running `q`.

          ```shellSession
          $ SSL_CERT_FILE=/tmp/self-signed-cert.pem q --verbose www.example.com A @tls://dnsvizor.mydomain.example
          ```
        '';
      }
      {
        instruction = ''
          Send encrypted DNS queries using `DNS-over-HTTPS`:

          ```shellSession
          $ SSL_CERT_FILE=/tmp/self-signed-cert.pem q --verbose www.example.com A @https://dnsvizor.mydomain.example
          ```
        '';
      }
      {
        instruction = ''
          Go back to the [Dashboard](https://127.0.0.1:4443/dashboard) page, you should see those numbers, such as `Total queries`, have changed.
        '';
      }
      {
        instruction = ''
          Go to the [Query log](https://127.0.0.1:4443/querylog) page, you should see domains you just queried.
        '';
      }
      {
        instruction = ''
          DNSvizor supports blocking DNS resolution for some domains.
          You can specify them as boot parameters.

          Go to the [Blocklist](https://127.0.0.1:4443/blocklist) page.
          Enter the password `password`.
          User can be anything you like.
          You can see some blocked domains we already specified.

          Query one of them:

          ```shellSession
          $ q --verbose --format raw block1.cli.example.com A @dnsvizor.mydomain.example
          ```

          You should see `status: NXDOMAIN` and `ANSWER: 0` in the output.
          This means there is no answer to your DNS query.
          You should also see `appears in blocklist boot-parameter` in the output.
        '';
      }
      {
        instruction = ''
          Blocked domains can also be specified using URLs.
          DNSvizor will fetch them using those URLs.

          Go to the [Blocklist](https://127.0.0.1:4443/blocklist) page, you can see some blocked domain lists we already specified.

          Query one of them:

          ```shellSession
          $ q --verbose --format raw block1.url.example.com A @dnsvizor.mydomain.example
          ```

          You should see `status: NXDOMAIN` and `ANSWER: 0` in the output.
          You should also see `appears in blocklist http://10.0.0.1/block-list-4` in the output.
        '';
      }
      {
        instruction = ''
          In the [Blocklist](https://127.0.0.1:4443/blocklist) page, you can also add or delete blocked domains.

          Add one, query it and check the result.

          You should see a similar output as before.  But this time, it shows `appears in blocklist web-ui`.

          Delete the domain you just added, query it and check the result.

          You should see the normal result again.
        '';
      }
      {
        instruction = ''
          Now go back to the [Dashboard](https://127.0.0.1:4443/dashboard) page, you should see the number of "Queries blocked" has changed.
        '';
      }
    ];
    tests.dns-dualstack-recursive.module = import ./services/dnsvizor/tests/dns.nix (
      args
      // {
        exampleName = "Enable DNSvizor as a dual-stack recursive DNS resolver";
        resolverKind = "recursive";
        useNetworkd = false;
        useNftables = false;
      }
    );
    inherit problem;
    links = { inherit webInterfaceManual; };
  };
}
