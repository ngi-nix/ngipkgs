{
  writeShellScriptBin,
  devshellEnv,
}:
let
  cmd = writeShellScriptBin "welcome" ''
    cat <<EOF
    ${devshellEnv.eval.config.devshell.motd}
    EOF
  '';
in
cmd.overrideAttrs (_: {
  meta.description = "shows the welcome message";
})
