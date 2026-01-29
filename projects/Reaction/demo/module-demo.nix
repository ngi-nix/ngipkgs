{
  config,
  lib,
  ...
}:
let
  cfg = config.services.reaction;
in
{
  config = lib.mkIf cfg.enable {
    # It seems ssh sends an empty password before prompting the user for a password
    # Which is causing the spurious unix_chkpwd log entry to occur
    services.openssh.settings.PermitEmptyPasswords = lib.mkForce "no";
  };
}
