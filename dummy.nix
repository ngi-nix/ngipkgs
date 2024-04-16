# Purpose of this dummy configuraion:
#   1. Define options that anyone copying from other files in
#      `/configs/**/*.nix` will have defined anyways.
#      The reason here is just to get rid of warnings and remove noise
#      from the other files.
#   2. Use the unbootable module so that we can evaluate the toplevel
#      without caring about boot. This will usually be overriden with
#      `pkgs.lib.mkForce` whenver we want to boot the system.
#      The fact that we use this module is also hidden here, not to
#      confuse anyone just wanting to copy paste from other files in
#      `/configs/**/*.nix`.
{...}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "23.05";

  # See the module in `/modules/unbootable.nix`.
  unbootable = true;
}
