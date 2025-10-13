{
  lib,
  fetchgit,
  recutils,
  buildGoModule,
  gitUpdater,
  writeShellApplication,
  nix,
  _experimental-update-script-combinators,
}:
buildGoModule (finalAttrs: {
  pname = "taldir";
  version = "1.0.5";

  src = fetchgit {
    url = "https://git.taler.net/taldir.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZKNkMV0IV6E+yCQeabGXpIQclx1S4YEgFn4whGXTaks=";
  };

  vendorHash = "sha256-QCwakJTpRP7VT69EzQeInCCGBuNu3WsNCytnQcBdKQw=";

  nativeBuildInputs = [
    recutils
  ];

  # From Makefile
  preBuild = ''
    mkdir -p internal/gana

    pushd third_party/gana/gnu-taler-error-codes
    make taler_error_codes.go
    popd

    cp third_party/gana/gnu-taler-error-codes/taler_error_codes.go internal/gana/
  '';

  subPackages = [
    "cmd/taldir-cli"
    "cmd/taldir-server"
  ];

  # dial error (dial tcp [::1]:5432: connect: connection refused)
  doCheck = false;

  passthru = {
    updateScriptSrc = gitUpdater { rev-prefix = "v"; };
    updateScriptVendor = writeShellApplication {
      name = "update-taldir-vendorHash";
      runtimeInputs = [ nix ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="''${UPDATE_NIX_ATTR_PATH:-taldir}"

        oldhash="$(nix-instantiate . --eval --strict -A "$UPDATE_NIX_ATTR_PATH.goModules.drvAttrs.outputHash" | cut -d'"' -f2)"
        newhash="$(nix-build -A "$UPDATE_NIX_ATTR_PATH.goModules" --no-out-link 2>&1 | tail -n3 | grep 'got:' | cut -d: -f2- | xargs echo || true)"

        if [ "$newhash" == "" ]; then
          echo "No new vendorHash."
          exit 0
        fi

        fname="$(nix-instantiate --eval -E "with import ./. {}; (builtins.unsafeGetAttrPos \"version\" $UPDATE_NIX_ATTR_PATH).file" | cut -d'"' -f2)"

        sed -i "s/$oldhash/$newhash/" "$fname"
      '';
    };
    updateScript = _experimental-update-script-combinators.sequence [
      finalAttrs.passthru.updateScriptSrc.command
      (lib.getExe finalAttrs.passthru.updateScriptVendor)
    ];
  };

  meta = {
    homepage = "https://git.taler.net/taldir.git";
    description = "Directory service to resolve wallet mailboxes by messenger addresses.";
    license = lib.licenses.agpl3Plus;
  };
})
