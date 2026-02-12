# assume this is run from the root of ngipkgs
update() {
  nixpkgs="$1"
  package="$2"
  commit="${3:-false}"

  nix-shell "$nixpkgs"/maintainers/scripts/update.nix \
    --arg include-overlays '[ (final: prev: (import ./. { }).ngipkgs) ]' \
    --argstr skip-prompt true \
    --argstr package "$package" \
    --argstr commit "$commit"
}
