# assume this is run from the root of ngipkgs
update() {
  nixpkgs="$1"
  nix_update="$2"
  package="$3"
  commit="${4:-false}"

  nix-shell "$nixpkgs"/maintainers/scripts/update.nix \
    --arg include-overlays '[ (final: prev: (import ./. { }).ngipkgs) ]' \
    --argstr skip-prompt true \
    --argstr package "$package" \
    --argstr commit "$commit" \
    --arg get-script "pkg: pkg.updateScript or \"$nix_update\""
}
