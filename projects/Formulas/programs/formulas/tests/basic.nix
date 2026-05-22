{ pkgs, ... }:
{
  name = "formulas-basic-test";

  machine = {
    programs.formulas.enable = true;
  };

  testScript = ''
    start_all()
    machine.succeed("formulas --help | grep -q 'Work with Excel'")
    machine.succeed("formulas --version")
    machine.succeed("python3 -c 'import formulas; print(formulas.__version__)'")
  '';
}
