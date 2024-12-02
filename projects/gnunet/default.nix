{
  pkgs,
  sources,
  ...
}@args:
{
  packages = {
    inherit (pkgs)
      gnunet
      gnunet-gtk
      gnunet-messenger-cli
      libgnurl
      ;
  };
  nixos = {
    modules.services.gnunet = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/gnunet.nix";
    tests = null;
    examples = null;
  };
}
