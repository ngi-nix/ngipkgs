{
  sources,
  pkgs,
  ...
}:
{
  name = "reoxide";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.reoxide
          sources.modules.services.reoxided
          sources.examples.ReOxide."Enable reoxided"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      simple_plugin = "${pkgs.reoxide-plugin-simple}/lib/libsimple.so";
    in
    ''
      start_all()

      machine.wait_for_unit("reoxided.service")

      # copy simple plugin to plugins directory
      machine.succeed("mkdir -p ~/.local/share/reoxide/plugins")
      machine.succeed("cp ${simple_plugin} ~/.local/share/reoxide/plugins/")

      machine.systemctl("restart reoxided.service")
      machine.wait_for_console_text("libsimple.so")
    '';
}
