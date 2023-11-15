{
  fetchFromGitHub,
  buildGoModule,
}: let
  version = "0.7.4";
in
  buildGoModule {
    pname = "ipfs-sniffer";
    inherit version;

    src = fetchFromGitHub {
      owner = "ipfs-search";
      repo = "ipfs-sniffer";
      rev = "v${version}-sniffer";
      hash = "sha256-T4tjJV4LxQopwsPzbbf9OwyCer6q9d4kWWJ7CuUmSPk=";
    };

    vendorSha256 = "sha256-xc1biJF4zicosSTFuUv82yvOYpbuY3h++rhvD+5aWNE=";

    doCheck = false;
  }
