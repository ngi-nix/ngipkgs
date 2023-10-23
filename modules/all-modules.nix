modulesPath: {
  # LiberaForms is intentionally disabled.
  # Refer to <https://github.com/ngi-nix/ngipkgs/issues/40>.
  #liberaforms = import ./liberaforms.nix;
  flarum = import ./flarum.nix;
  pretalx = import ./pretalx.nix;
  unbootable = import ./unbootable.nix;
}
