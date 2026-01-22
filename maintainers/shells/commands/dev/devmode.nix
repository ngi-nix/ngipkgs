# live overview watcher
{
  devmode,
}:
let
  cmd = devmode.override {
    buildArgs = "-A overview --show-trace -v";
  };
in
cmd.overrideAttrs {
  meta.description = "watches files for changes and live reloads the overview";
}
