{
  lib,
  rustPlatform,
  fetchgit,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage {
  pname = "depolymerization";
  version = "0-unstable-2024-03-18";

  src = fetchgit {
    url = "https://git.taler.net/depolymerization.git/";
    rev = "80ded0febe5acbfa64cef3d84846b4a1300ea97f";
    hash = "sha256-wb1IxaiM+uGEa9l8Iz0fDluIWZgVMnT8BUZ/R5M3dcU=";
  };

  cargoHash = "sha256-aU4edNBxQfzFAdAbY5mkw9xl9pcC6ao027HakNX9BW8=";

  patches = [./0001-Fix-status-test-docs.patch];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = with lib; {
    description = "Wire gateway for Bitcoin/Ethereum";
    homepage = "https://git.taler.net/depolymerization.git/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [];
  };
}
