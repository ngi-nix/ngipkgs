{
  # LiberaForms is intentionally disabled.
  # Refer to <https://github.com/ngi-nix/ngipkgs/issues/40>.
  #liberaforms = import ./liberaforms.nix;
  flarum = import ./flarum.nix;
  kbin = import ./kbin.nix;
  mcaptcha = import ./mcaptcha.nix;
  pretalx = import ./pretalx.nix;
  unbootable = import ./unbootable.nix;
  vula = import ./vula.nix;
}
