{
  lib,
  rustPlatform,
  fetchCrate,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "atomic-cli";
  version = "0.34.5";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-97JltSMuNETcgm5jfb2tOjwgw87J0u8qs+TIViT0PBo=";
  };

  cargoHash = "sha256-NehXV26PBOD+V1KZo8I2EQ7Hp32ccT6e51v5qESj+l4=";

  doCheck = false; # TODO(jl): broken upstream

  meta = with lib; {
    description = "CLI tool to create, store, query, validate and convert Atomic Data";
    homepage = "https://crates.io/crates/atomic-cli";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
