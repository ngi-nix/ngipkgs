{
  rustPlatform,
  fetchFromGitHub,
}:
let
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mCaptcha";
    repo = "cache";
    rev = "v${version}";
    hash = "sha256-Uryk8TSrI/Hkn3qBgp4fNSYNaG+4ba9Zcve3ht7q7yw=";
  };
in
rustPlatform.buildRustPackage {
  pname = "cache";
  inherit version src;

  useFetchCargoVendor = true;
  cargoHash = "sha256-uQ/Bvee21iZxot6QULaW7kRiepD5Xlg6ofFRN+bP9AM=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];

  # error[E0425]: cannot find function `register_commands` in module `$crate::commands`
  doCheck = false;
}
