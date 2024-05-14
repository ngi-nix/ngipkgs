{
  sources,
  pkgs,
  ...
}: {
  name = "vula";

  nodes = {
    server = {config, ...}: {
      imports = [
        sources.modules.default
        sources.modules."services.vula"
      ];
      services.vula.enable = true;
    };
  };

  testScript = {nodes, ...}: ''
    start_all()
  '';
}
