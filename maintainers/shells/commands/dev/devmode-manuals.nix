# live overview+manual watcher
{
  lib,
  devmode,
  writeShellApplication,
}:
writeShellApplication {
  name = "devmode-manuals";
  text = ''
    ${lib.getExe (
      devmode.override {
        buildArgs = "-A overview-with-manuals --show-trace -v";
      }
    )}
  '';
  meta.description = "watches files for changes and live reloads the overview with the manuals";
}
