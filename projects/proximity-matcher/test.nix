{
  sources,
  ...
}:
{
  name = "proximity-matcher";

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
          sources.modules.services.proximity-matcher
          sources.examples.proximity-matcher.basic
        ];

        environment.systemPackages = with pkgs; [
          jq
        ];

        # Generate some data for testing
        systemd.services.proximity-matcher_setup = {
          wantedBy = [ "multi-user.target" ];
          before = [ "proximity-matcher.service" ];
          script = ''
            mkdir -p /var/lib/proximity-matcher
            cd /var/lib/proximity-matcher
            mkdir testfiles
            cp ${config.services.proximity-matcher.package.src}/LICENSE testfiles
            ${lib.getExe' config.services.proximity-matcher.package "prepare_tlsh_hashes"} -i testfiles -o hashes
            ${lib.getExe' config.services.proximity-matcher.package "create-vpt-pickle"} -i hashes -o hashes.pickle
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
        r"""curl -s http://127.0.0.1:5000/tlsh/$(cat ${nodes.machine.services.proximity-matcher.hashesPath})""" \
        " | jq -cS ." \
        r""" | grep -E '^{"distance":0,"match":true,"tlsh":"'"$(cat ${nodes.machine.services.proximity-matcher.hashesPath})"'"}$'"""
      )
    '';
}
