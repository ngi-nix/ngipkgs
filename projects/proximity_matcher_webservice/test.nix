{
  sources,
  ...
}:
{
  name = "proximity_matcher_webservice";

  nodes = {
    machine =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.proximity_matcher_webservice
          sources.examples.proximity_matcher_webservice.basic
        ];

        environment.systemPackages = with pkgs; [
          jq
        ];

        # Generate some data for testing
        systemd.services.proximity_matcher_webservice_setup = {
          wantedBy = [ "multi-user.target" ];
          before = [ "proximity_matcher_webservice.service" ];
          script = ''
            mkdir -p /var/lib/proximity_matcher_webservice
            cd /var/lib/proximity_matcher_webservice
            mkdir testfiles
            cp ${config.services.proximity_matcher_webservice.package.src}/LICENSE testfiles
            ${lib.getExe' config.services.proximity_matcher_webservice.package "prepare_tlsh_hashes"} -i testfiles -o hashes
            ${lib.getExe' config.services.proximity_matcher_webservice.package "create-vpt-pickle"} -i hashes -o hashes.pickle
          '';
        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_open_port(5000)
      machine.succeed(
        r"""curl -s http://127.0.0.1:5000/tlsh/$(cat ${nodes.machine.services.proximity_matcher_webservice.hashesPath})""" \
        " | jq -cS ." \
        r""" | grep -E '^{"distance":0,"match":true,"tlsh":"'"$(cat ${nodes.machine.services.proximity_matcher_webservice.hashesPath})"'"}$'"""
      )
    '';
}
