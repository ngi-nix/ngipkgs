{
  sources,
  ...
}:

{
  name = "Kazarma";

  nodes = {
    machine =
      { config, ... }:
      let
        certs = import "${sources.inputs.nixpkgs}/nixos/tests/common/acme/server/snakeoil-certs.nix";
        inherit (config.services) honk;
      in
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.kazarma
          sources.examples.Kazarma."Enable kazarma"
        ];

        security.pki.certificateFiles = [
          certs.ca.cert
        ];

        networking.hosts = {
          "127.0.0.1" = [
            honk.servername
          ];
        };

        services.caddy = {
          enable = true;
          globalConfig = ''
            local_certs
            pki {
              ca {
                intermediate {
                  cert ${certs.ca.cert}
                  key ${certs.ca.key}
                }
              }
            }
          '';
          virtualHosts = {
            ${honk.servername} = {
              extraConfig = ''
                reverse_proxy http://127.0.0.1:${toString honk.port}
              '';
            };
          };
        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("kazarma.service")
    '';
}
