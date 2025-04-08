{
  fetchgit,
  lib,
  recutils,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "taldir";
  version = "1.0.3";

  src = fetchgit {
    url = "https://git.taler.net/taldir.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-axVQ687cGvxGEKECh3HmbTAFwI/YaCtPvtRU5bWsYYI=";
  };

  vendorHash = "sha256-V/UzUS3eMKnEhgaipsHoodAlZxuEkZM/ALliU1TNuYg=";

  /*
    NOTE: regenerate the `./go.sum` file on each update:
    ```shellSession
      $ nix-shell -p go
      $ git clone https://git.taler.net/taldir.git && cd taldir
      $ go mod tidy
    ```
  */

  postPatch = ''
    cp ${./go.sum} go.sum
  '';

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

  meta = {
    homepage = "https://git.taler.net/taldir.git";
    description = "Directory service to resolve wallet mailboxes by messenger addresses.";
    license = lib.licenses.agpl3Plus;
  };
})
