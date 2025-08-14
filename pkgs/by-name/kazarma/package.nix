{
  beamPackages,
  cacert,
  fetchFromGitHub,
  fetchFromGitLab,
  lib,
}:
let
  # https://github.com/elixir-lang/elixir/issues/13976
  beamPackages' = beamPackages.extend (self: super: { elixir = self.elixir_1_17; });
  cldr = fetchFromGitHub {
    owner = "elixir-cldr";
    repo = "cldr";
    tag = "v2.37.2";
    hash = "sha256-dDOQzLIi3zjb9xPyR7Baul96i9Mb3CFHUA+AWSexrk4=";
  };
in
beamPackages'.mixRelease rec {
  pname = "kazarma";
  version = "1.0.0-alpha.1-unstable-2025-06-30";

  src = fetchFromGitLab {
    group = "technostructures";
    owner = "kazarma";
    repo = "kazarma";
    rev = "2cd1ca80d3c54e54a11fd3b9079f6c4fa6330302";
    fetchSubmodules = true;
    hash = "sha256-Ry5xgGeVzzjnumlYXrU8vzvf1l7IeVfSL+RvGPmWq9U=";
  };

  nativeBuildInputs = [ cacert ];

  patches = [
    ./cacert.patch
    ./data_dir.patch
  ];

  postPatch = ''
    substituteInPlace config/config.exs \
      --replace-fail "@cacert@" "$NIX_SSL_CERT_FILE"
  '';

  preConfigure = ''
    rm -r deps
  '';

  mixFodDeps = beamPackages'.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit version src;
    hash = "sha256-APOzFj+3yFrpDV8U2bZCJwZC9iHGISeKcZUGS8d3mtA=";
  };

  preBuild = ''
    mkdir -p cldr
    ln -s ${cldr}/priv/cldr/locales cldr/
  '';

  meta = {
    description = "Matrix bridge to ActivityPub";
    homepage = "https://kazar.ma/";
    downloadPage = "https://gitlab.com/technostructures/kazarma/kazarma";
    license = lib.licenses.agpl3Only;
    teams = [ lib.teams.ngi ];
  };
}
