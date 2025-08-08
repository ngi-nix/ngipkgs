{
  sources,
  pkgs,
  ...
}:
{
  name = "pagedjs";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.pagedjs
          sources.examples.PagedJS."Enable pagedjs"
          (sources.inputs.nixpkgs + "/nixos/tests/common/user-account.nix")
          (sources.inputs.nixpkgs + "/nixos/tests/common/x11.nix")
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # Generate a pdf from the HTML file
      machine.succeed("pagedjs-cli -i /etc/pagedjs.html -o /etc/pagedjs-example.pdf")

      # Check if the PDF was created successfully
      machine.execute("evince /etc/pagedjs-example.pdf >&2 &")

      machine.sleep(3)

      machine.screenshot("pagedjs-example")
    '';
}
